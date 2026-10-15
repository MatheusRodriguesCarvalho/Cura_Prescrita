extends Node2D

const DURACAO_FASE := 0.35

@onready var consultorio: Node2D = $Consultorio
@onready var ala_medicacao: Node2D = $AlaMedicacao

@onready var guia: Control = $CanvasLayer/GuiaMedico
@onready var botao_ir_ala: TextureButton = $CanvasLayer/BotoesIr/BotaoIrMedicacao
@onready var botao_ir_consultorio: TextureButton = $CanvasLayer/BotoesIr/BotaoIrConsultorio

@onready var paciente: Paciente = $Consultorio/Mundo/Paciente
@onready var sombra: TextureRect = $CanvasLayer/TransicaoSombra

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
	
	_avisar_guia_atualizado()

func _exit_tree() -> void:
	GerenciadorPausa.habilitar(false)


## -- TROCA DE SALA --
func ir_para_ala() -> void:
	_trocar_sala(true)

func ir_para_consultorio() -> void:
	_trocar_sala(false)

func _trocar_sala(para_medicacao: bool) -> void:
	if _em_transicao:
		return
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


func _avisar_guia_atualizado() -> void:
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


func _mostrar_popup_guia(detalhes: String) -> void:
	var painel := PanelContainer.new()
	painel.set_anchors_and_offsets_preset(Control.PRESET_CENTER, Control.PRESET_MODE_MINSIZE)
	painel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	painel.grow_vertical = Control.GROW_DIRECTION_BOTH
	
	var caixa := VBoxContainer.new()
	painel.add_child(caixa)
	
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
	
	$CanvasLayer.add_child(painel)


## -- TEMPO E TELAS --
func _on_tempo_esgotado() -> void:
	print("Time Out, fim da Fase")
	GerenciadorTempo.encerrar_fase()
	
	## get_tree().change_scene_to_file("res://Scenes/visual_novel.tscn")
	# TODO: Transição, tela de estatisticas do dia e troca de Cena
