extends Node2D

var paciente_atual: Paciente = null
var atendimento_concluido: bool = false

func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_button_pressed() -> void:
	if paciente_atual == null:
		_chamar_novo_paciente()
	elif atendimento_concluido:
		_liberar_paciente_atual()
		_chamar_novo_paciente()
	else:
		print("Atendimento em andamento, finalize antes de chamar o próximo.")

func _chamar_novo_paciente() -> void:
	paciente_atual = GerenciadorPacientes.chamar_paciente(self)
	if paciente_atual:
		paciente_atual.position = Vector2(200, 150)
	atendimento_concluido = false

func _liberar_paciente_atual() -> void:
	GerenciadorPacientes.liberar_paciente(paciente_atual.protocolo)
	paciente_atual.queue_free()
	paciente_atual = null
