extends Node2D

const DURACAO_FASE := 0.35

@export var consultorio: Node2D
@export var ala_medicacao: Node2D

@export var guia: Control
@export var dialogoUI: Control
@export var botao_ir_ala: TextureButton
@export var botao_ir_consultorio: TextureButton

@export var paciente: Paciente
@export var sombra: TextureRect

@export_category("Botoes de Acesso")
@export var botao_paciente: Node2D
@export var botao_guia: Node2D
@export var botao_computador: Node2D
@export var botao_produzir: Node2D
@export var computador: Node2D
@export var ficha: Control

@export var musica_cena: String = "consultorio"  ## subpasta em Sons/Musicas; vazio = sem música

@export var seq: TutorialSequencia

## var paciente_atual: Paciente = null
## var atendimento_concluido: bool = false
var _em_transicao := false


func _ready() -> void:
	_alternar(consultorio, ala_medicacao)
	
	botao_ir_consultorio.hide()
	botao_ir_ala.hide()
	sombra.hide()
	
	GerenciadorPacientes.registrar_paciente_presente(paciente)
	
	GerenciadorAla.ficha_finalizada.connect(botao_ir_ala.show)
	GerenciadorAla.editar_ficha.connect(botao_ir_ala.hide)
	GerenciadorAla.novo_paciente_chamado.connect(botao_ir_ala.hide)
	
	## Conexão com o tempo
	GerenciadorTempo.preparar_dia()
	GerenciadorTempo.tempo_esgotado.connect(_on_tempo_esgotado)
	## GerenciadorTempo.iniciar_fase()
	
	GerenciadorPausa.habilitar(true)
	GerenciadorTutorial.iniciar(seq)
	
	if musica_cena != "":
		GerenciadorAudio.tocar_musica_cena(musica_cena, true)
	
	computador.desligar()
	if not _avisar_guia_atualizado():
		computador.ligar()

func _exit_tree() -> void:
	GerenciadorPausa.habilitar(false)


func _unhandled_input(event: InputEvent) -> void:
	if _em_transicao or not event.is_pressed() or event.is_echo():
		return
	
	if event.is_action_pressed("alternar_sala"):
		_trocar_sala(not ala_medicacao.visible)
	elif ala_medicacao.visible:
		if event.is_action_pressed("produzir_remedio"):
			botao_produzir.produzir()
	else:
		if event.is_action_pressed("abrir_guia"):
			guia.fechar() if guia.visible else botao_guia.abrir()
		elif event.is_action_pressed("abrir_ficha"):
			ficha.fechar() if ficha.visible else botao_computador.abrir_ficha()
		elif event.is_action_pressed("chamar_paciente") and not guia.visible and not ficha.visible:
			botao_paciente.chamar()

## -- TROCA DE SALA --
func ir_para_ala() -> void:
	_trocar_sala(true)

func ir_para_consultorio() -> void:
	_trocar_sala(false)

func _trocar_sala(para_medicacao: bool) -> void:
	if _em_transicao:
		return
	
	GerenciadorAudio.tocar("troca")
	_em_transicao = true
	
	# Esconde ambos os botões durante o wipe; _aplicar_troca mostra o certo
	botao_ir_ala.hide()
	botao_ir_consultorio.hide()
	
	var largura := get_viewport_rect().size.x
	# Consultório -> Medicação: sombra entra pela esquerda e sai pela direita.
	# Medicação -> Consultório: o inverso.
	var x_inicio := -largura if para_medicacao else largura
	var x_fim := largura if para_medicacao else -largura
	
	sombra.position.x = x_inicio
	sombra.show()
	
	var tween := create_tween()
	tween.tween_property(sombra, "position:x", 0.0, DURACAO_FASE)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(_aplicar_troca.bind(para_medicacao))
	tween.tween_property(sombra, "position:x", x_fim, DURACAO_FASE)\
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(_finalizar_transicao)


func _aplicar_troca(para_medicacao: bool) -> void:
	dialogoUI.visible = not para_medicacao
	
	if para_medicacao:
		_alternar(ala_medicacao, consultorio)
		botao_ir_consultorio.show()
	else:
		_alternar(consultorio, ala_medicacao)
		botao_ir_ala.show()
	_mover_remedio_para(ala_medicacao if para_medicacao else consultorio)

func _finalizar_transicao() -> void:
	sombra.hide()
	_em_transicao = false

func _mover_remedio_para(sala: Node) -> void:
	if not GerenciadorAla.remedio_atual:
		return
	var local := sala.get_node("Mundo/Mesa/LocalRemedio")
	GerenciadorAla.remedio_atual.reparent(local)
	GerenciadorAla.remedio_atual.global_position = local.global_position

func _alternar(mostrar: Node, esconder: Node) -> void:
	esconder.hide()
	esconder.process_mode = Node.PROCESS_MODE_DISABLED
	mostrar.show()
	mostrar.process_mode = Node.PROCESS_MODE_INHERIT


func _on_botao_ir_consultorio_pressed() -> void:
	ir_para_consultorio()

func _on_botao_ir_medicacao_pressed() -> void:
	ir_para_ala()



func _avisar_guia_atualizado() -> bool:
	var fase := GerenciadorPacientes.fase_atual
	var linhas: Array[String] = []
	
	if GerenciadorPacientes.noticia_do_dia(fase) != null:
		linhas.append("• Notícia do dia")
	
	var novas := 0
	for id in GerenciadorPacientes.doencas_desbloqueadas:
		if GerenciadorPacientes.doencas_desbloqueadas[id] == fase:
			novas += 1
	if novas > 0:
		linhas.append("• %d nova(s) doença(s) catalogada(s)" % novas)
	
	if not linhas.is_empty():
		_mostrar_popup_guia("\n".join(linhas))
		return true
	return false

func _mostrar_popup_guia(detalhes: String) -> void:
	var raiz := Control.new()
	raiz.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	raiz.mouse_filter = Control.MOUSE_FILTER_STOP
	raiz.gui_input.connect(func(ev: InputEvent):
		if ev is InputEventMouseButton and ev.pressed:
			raiz.queue_free())
	
	var painel := PanelContainer.new()
	painel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	painel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	painel.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var margem := MarginContainer.new()
	for lado in ["margin_left", "margin_top", "margin_right", "margin_bottom"]:
		margem.add_theme_constant_override(lado, 16)
	painel.add_child(margem)
	
	var caixa := VBoxContainer.new()
	caixa.add_theme_constant_override("separation", 8)  ## espaço entre título, texto e botões
	margem.add_child(caixa)
	
	
	var titulo := Label.new()
	titulo.text = "Guia Médico atualizado"
	caixa.add_child(titulo)
	
	var corpo := Label.new()
	corpo.text = "Uma nova edição foi impressa com novas informações:\n" + detalhes
	caixa.add_child(corpo)
	
	var botoes := HBoxContainer.new()
	botoes.alignment = BoxContainer.ALIGNMENT_END
	caixa.add_child(botoes)
	
	var fechar := Button.new()
	fechar.text = "Fechar"
	fechar.pressed.connect(painel.queue_free)
	botoes.add_child(fechar)
	
	var abrir := Button.new()
	abrir.text = "Abrir guia"
	abrir.pressed.connect(func():
		painel.queue_free()
		guia.abrir())
	botoes.add_child(abrir)
	raiz.add_child(painel)   # o painel (e seus botões) continua recebendo cliques normalmente
	
	fechar.pressed.connect(raiz.queue_free)
	abrir.pressed.connect(func():
		raiz.queue_free()
		guia.abrir())
	
	raiz.tree_exited.connect(computador.ligar)
	
	$CanvasLayer.add_child(raiz)


## -- TEMPO E TELAS --
func _on_tempo_esgotado() -> void:
	print("Time Out, fim da Fase")
	GerenciadorTempo.encerrar_fase()
	
	## get_tree().change_scene_to_file("res://Scenes/visual_novel.tscn")
	# TODO: Transição, tela de estatisticas do dia e troca de Cena
