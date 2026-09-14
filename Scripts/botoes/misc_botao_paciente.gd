extends Node2D

var paciente_atual: Paciente = null
var atendimento_concluido: bool = false

@onready var area_clique: Area2D = $Area2D
@onready var set_point: Node = $"../../.."

func _ready() -> void:
	area_clique.input_event.connect(_on_area_clique_input_event)

func _on_area_clique_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_paciente_call()

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
	paciente_atual = GerenciadorPacientes.chamar_paciente(set_point)
	if paciente_atual:
		paciente_atual.position = Vector2(150, 200)
		paciente_atual.scale = Vector2(2, 2)
	atendimento_concluido = false

func _liberar_paciente_atual() -> void:
	GerenciadorPacientes.liberar_paciente(paciente_atual.protocolo)
	paciente_atual.queue_free()
	paciente_atual = null
