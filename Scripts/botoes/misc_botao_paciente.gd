extends Node2D

var paciente_atual: Paciente = null
var atendimento_concluido: bool = false
var dia_iniciado: bool = false

@onready var area_clique: Area2D = $Area2D
@onready var set_point: Node = $"../../.."

func _ready() -> void:
	area_clique.input_event.connect(_on_area_clique_input_event)
	dia_iniciado = false

func _on_area_clique_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_chamar_ou_verificar()

func _chamar_ou_verificar() -> void:
	if GerenciadorPacientes.tem_atendimento_ativo():
		print("Atendimento em andamento — finalize antes de chamar outro.")
		return
	
	var paciente := GerenciadorPacientes.chamar_paciente()
	if paciente == null:
		return
	
	GerenciadorTempo.registrar_acao(15.0)
	if not dia_iniciado:
		dia_iniciado = true
		GerenciadorTempo.iniciar_fase()

func _paciente_call() -> void:
	if paciente_atual == null:
		_chamar_novo_paciente()
	elif atendimento_concluido:
		_liberar_paciente_atual()
		_chamar_novo_paciente()
	else:
		print("Atendimento em andamento, finalize antes de chamar o próximo.")
		print("Paciente protocolo: ", paciente_atual.protocolo)
	
	print("Nome do Paciente: ", paciente_atual.nome)
	print("Nome Doença: ", paciente_atual.doenca.nome)

func _chamar_novo_paciente() -> void:
	paciente_atual = GerenciadorPacientes.chamar_paciente()
	if paciente_atual:
		paciente_atual.position = Vector2(150, 200)
		paciente_atual.scale = Vector2(2, 2)
	atendimento_concluido = false
	## GerenciadorAla.novo_paciente_chamado.emit()

func _liberar_paciente_atual() -> void:
	GerenciadorPacientes.liberar_paciente(paciente_atual.protocolo)
	paciente_atual.queue_free()
	paciente_atual = null
