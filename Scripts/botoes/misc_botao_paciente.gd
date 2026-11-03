extends Node2D

var paciente_atual: Paciente = null
var atendimento_concluido: bool = false
var dia_iniciado: bool = false

@onready var area_clique: Area2D = $Area2D
@export var set_point: Node

func _ready() -> void:
	area_clique.input_event.connect(_on_area_clique_input_event)
	dia_iniciado = false

func _on_area_clique_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		chamar()

func chamar() -> void:
	if GerenciadorPacientes.tem_atendimento_ativo():
		TooltipInfo.aviso.emit("Ainda há um paciente na sala...")
		print("Atendimento em andamento — finalize antes de chamar outro.")
		return
	
	var paciente := GerenciadorPacientes.chamar_paciente()
	if paciente == null:
		return
	
	GerenciadorAudio.tocar("digitacao")
	## GerenciadorTempo.registrar_acao(15.0)
	
	if not dia_iniciado:
		dia_iniciado = true
		GerenciadorTempo.iniciar_fase()
