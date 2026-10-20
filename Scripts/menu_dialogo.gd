extends Control

var paciente_atual: Paciente = null

## O primeiro botão da cena vira o molde (mantém seu estilo); os demais são removidos.
@onready var lista: VBoxContainer = $VBoxContainer
var _modelo: Button

## Os botões só são refeitos quando o paciente muda (o nó Paciente é permanente,
## então a identidade é o protocolo, não o nó).
var _protocolo_montado := ""

## Invalida falas pendentes (await) quando outra opção é escolhida ou o paciente muda.
var _id_acao := 0

## --- Juice ---
const ENTRADA_DURACAO := 0.4
const ENTRADA_ATRASO := 0.09     ## atraso entre um balão e o seguinte
const SAIDA_DURACAO := 0.2
const RESPIRO_AMPLITUDE := Vector2(0.001, 0.002)  ## faixa sorteada de escala extra
const RESPIRO_TEMPO := Vector2(1.5, 1.9)        ## faixa sorteada de duração (s)
const RESPIRO_ROTACAO := 0.1                    ## graus

var _id_anim := 0
var _fechando := false
var _tweens: Array[Tween] = []

var texto_botao_protocolo: Array[String] = [
	"Pedir por Protocolo",
	"Mais Informações",
	"Solicitar Código",
]
var texto_botao_sintoma: Array[String] = [
	"Como se sente?",
	"Tudo bem?",
	"Como está?",
	"Em que posso ajudar?",
]
var texto_botao_vida: Array[String] = [
	"Semana difícil...",
	"Como vai sua vida?",
	"O que tem feito de bom?",
]


func _ready() -> void:
	hide()
	_modelo = lista.get_child(0) as Button
	lista.remove_child(_modelo)
	for filho in lista.get_children():
		filho.queue_free()


func _exit_tree() -> void:
	if is_instance_valid(_modelo) and not _modelo.is_inside_tree():
		_modelo.free()


func abrir(paciente: Paciente) -> void:
	if visible and not _fechando and paciente_atual == paciente:
		_fechar()
		return
	paciente_atual = paciente
	_fechando = false
	
	if paciente.protocolo != _protocolo_montado:
		_protocolo_montado = paciente.protocolo
		_nova_acao()  ## paciente novo: cancela qualquer resposta pendente do anterior
		_reconstruir(_opcoes_do_paciente(paciente))
	
	_parar_tweens()
	_esconder_botoes()  ## invisíveis até o layout existir (evita piscar)
	global_position = paciente.global_position + Vector2(40, -60)
	show()
	
	var meu_id := _id_anim
	await get_tree().process_frame  ## espera o VBox calcular as posições
	if meu_id != _id_anim or not is_instance_valid(paciente):
		return
	
	GerenciadorAudio.tocar("dialogo")
	_animar_entrada(paciente.sprite.global_position)


func _nova_acao() -> int:
	_id_acao += 1
	return _id_acao


## --- Opções: dados, não botões fixos ---
## Para criar uma opção nova, basta acrescentar uma entrada aqui.
## "visivel" (opcional) esconde a opção quando for false.
func _opcoes_do_paciente(paciente: Paciente) -> Array:
	return [
		{"rotulos": texto_botao_protocolo, "acao": _on_opcao_protocolo},
		{"rotulos": texto_botao_sintoma, "acao": _on_opcao_sintoma},
		{"rotulos": texto_botao_vida, "acao": _on_opcao_vida,
			"visivel": not paciente.fala_vida_aleatoria().is_empty()},
	]


## Cada botão fica dentro de um "slot": o VBox posiciona o slot,
## e o botão pode se mover livremente dentro dele sem brigar com o container.
func _reconstruir(opcoes: Array) -> void:
	_parar_tweens()
	for filho in lista.get_children():
		lista.remove_child(filho)
		filho.queue_free()
	for o in opcoes:
		if not o.get("visivel", true):
			continue
		var rotulos: Array = o["rotulos"]
		
		var slot := Control.new()
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		lista.add_child(slot)
		
		var botao := _modelo.duplicate() as Button
		botao.text = rotulos[randi() % rotulos.size()]
		botao.pressed.connect(o["acao"])
		slot.add_child(botao)
		botao.set_anchors_preset(Control.PRESET_TOP_LEFT)
		botao.position = Vector2.ZERO
		
		slot.custom_minimum_size = botao.get_combined_minimum_size()
		slot.resized.connect(func(): botao.size = slot.size)


func _botoes() -> Array[Button]:
	var r: Array[Button] = []
	for slot in lista.get_children():
		if slot.get_child_count() > 0 and slot.get_child(0) is Button:
			r.append(slot.get_child(0))
	return r


func _esconder_botoes() -> void:
	for b in _botoes():
		b.modulate.a = 0.0
		b.scale = Vector2.ZERO
		b.rotation = 0.0
		b.mouse_filter = Control.MOUSE_FILTER_STOP


func _parar_tweens() -> void:
	_id_anim += 1
	for t in _tweens:
		if t and t.is_valid():
			t.kill()
	_tweens.clear()


## --- 1) Entrada: cresce do centro do paciente até a posição final ---
func _animar_entrada(origem_global: Vector2) -> void:
	var i := 0
	for botao in _botoes():
		var slot := botao.get_parent() as Control
		botao.size = slot.size
		botao.pivot_offset = botao.size / 2.0
		
		var centro_slot := slot.global_position + slot.size / 2.0
		botao.position = origem_global - centro_slot  ## centro do botão = centro do paciente
		botao.scale = Vector2.ZERO
		botao.modulate.a = 0.0
		
		var atraso := i * ENTRADA_ATRASO
		var t := botao.create_tween().set_parallel(true)
		t.tween_property(botao, "position", Vector2.ZERO, ENTRADA_DURACAO) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(atraso)
		t.tween_property(botao, "scale", Vector2.ONE, ENTRADA_DURACAO) \
			.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).set_delay(atraso)
		t.tween_property(botao, "modulate:a", 1.0, ENTRADA_DURACAO * 0.5).set_delay(atraso)
		t.chain().tween_callback(_respirar.bind(botao))
		_tweens.append(t)
		i += 1


## --- 2) Idle: infla e desinfla com leve balanço, cada balão com ritmo próprio ---
func _respirar(botao: Button) -> void:
	if not is_instance_valid(botao):
		return
	var amp := 1.0 + randf_range(RESPIRO_AMPLITUDE.x, RESPIRO_AMPLITUDE.y)
	var dur := randf_range(RESPIRO_TEMPO.x, RESPIRO_TEMPO.y)
	var rot := randf_range(0.5, RESPIRO_ROTACAO) * (1.0 if randf() > 0.5 else -1.0)
	
	var t := botao.create_tween().set_loops()
	t.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	t.tween_property(botao, "scale", Vector2.ONE * amp, dur)
	t.parallel().tween_property(botao, "rotation_degrees", rot, dur)
	t.tween_property(botao, "scale", Vector2.ONE, dur)
	t.parallel().tween_property(botao, "rotation_degrees", -rot, dur)
	_tweens.append(t)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _fechando:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not get_global_rect().has_point(get_global_mouse_position()):
			GerenciadorAudio.tocar("dialogo")
			_fechar()

func sair(_paciente: Paciente) -> void:
	_fechar()


## --- 3) Saída: esmaece e some ---
func _fechar() -> void:
	paciente_atual = null
	if not visible or _fechando:
		return
	_fechando = true
	_parar_tweens()
	var meu_id := _id_anim
	
	var t := create_tween().set_parallel(true)
	for botao in _botoes():
		botao.mouse_filter = Control.MOUSE_FILTER_IGNORE  ## não clicável enquanto some
		t.tween_property(botao, "modulate:a", 0.0, SAIDA_DURACAO)
		t.tween_property(botao, "scale", Vector2.ONE * 0.85, SAIDA_DURACAO)
	t.chain().tween_callback(func():
		if meu_id == _id_anim:
			hide()
			_fechando = false
	)
	_tweens.append(t)


## Cada ação guarda o paciente em variável local e fecha o menu ANTES de falar.
func _on_opcao_protocolo() -> void:
	GerenciadorAudio.tocar("dialogo")
	var p := paciente_atual
	_nova_acao()
	_fechar()
	if p:
		GerenciadorDialogos.pedir_protocolo(p)

func _on_opcao_sintoma() -> void:
	GerenciadorAudio.tocar("dialogo")
	var p := paciente_atual
	_nova_acao()
	_fechar()
	if p:
		GerenciadorDialogos.falar.emit(p.nome, p.doenca.fala_sintoma_aleatoria())

func _on_opcao_vida() -> void:
	GerenciadorAudio.tocar("dialogo")
	var p := paciente_atual
	var meu_id := _nova_acao()
	_fechar()
	if p == null:
		return
	var par: Dictionary = p.fala_vida_aleatoria()
	if par.is_empty():
		return
	var protocolo := p.protocolo
	
	GerenciadorDialogos.falar.emit("Alê", par["pergunta"])
	await get_tree().create_timer(GerenciadorDialogos.tempo_exibicao_2, false).timeout
	
	## Não responde se outra opção foi escolhida, o paciente trocou ou foi dispensado.
	if meu_id != _id_acao:
		return
	if is_instance_valid(p) and p.protocolo == protocolo:
		GerenciadorDialogos.falar.emit(p.nome, par["resposta"])
