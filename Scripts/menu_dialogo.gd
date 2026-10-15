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
	if visible and paciente_atual == paciente:
		_fechar()
		return
	paciente_atual = paciente
	
	if paciente.protocolo != _protocolo_montado:
		_protocolo_montado = paciente.protocolo
		_nova_acao()  ## paciente novo: cancela qualquer resposta pendente do anterior
		_reconstruir(_opcoes_do_paciente(paciente))
	
	global_position = paciente.global_position + Vector2(40, -60)
	show()

func _nova_acao() -> int:
	_id_acao += 1
	return _id_acao

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not get_global_rect().has_point(get_global_mouse_position()):
			_fechar()

func sair(_paciente: Paciente) -> void:
	_fechar()

func _fechar() -> void:
	hide()
	paciente_atual = null

## Cada ação guarda o paciente em variável local e fecha o menu ANTES de falar.
func _on_opcao_protocolo() -> void:
	var p := paciente_atual
	_nova_acao()
	_fechar()
	if p:
		GerenciadorDialogos.pedir_protocolo(p)

func _on_opcao_sintoma() -> void:
	var p := paciente_atual
	_nova_acao()
	_fechar()
	if p:
		GerenciadorDialogos.falar.emit(p.nome, p.doenca.fala_sintoma_aleatoria())

func _on_opcao_vida() -> void:
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

func _reconstruir(opcoes: Array) -> void:
	for filho in lista.get_children():
		lista.remove_child(filho)
		filho.queue_free()
	for o in opcoes:
		if not o.get("visivel", true):
			continue
		var rotulos: Array = o["rotulos"]
		var botao := _modelo.duplicate() as Button
		botao.text = rotulos[randi() % rotulos.size()]
		botao.pressed.connect(o["acao"])
		lista.add_child(botao)
