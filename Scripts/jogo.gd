extends Node2D

@onready var consultorio: Node2D = $Consultorio
@onready var ala_medicacao: Node2D = $AlaMedicacao
@onready var botao_ir_ala: TextureButton = $Consultorio/CanvasLayer/Control/BotaoIrMedicacao


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_alternar(consultorio, ala_medicacao)
	
	##botao_ir_ala.hide()
	GerenciadorAla.ficha_finalizada.connect(botao_ir_ala.show)
	GerenciadorAla.novo_paciente_chamado.connect(botao_ir_ala.hide)

func ir_para_ala() -> void:
	_alternar(ala_medicacao, consultorio)

func ir_para_consultorio() -> void:
	_alternar(consultorio, ala_medicacao)
	if GerenciadorAla.remedio_atual:
		var local := consultorio.get_node("Mundo/Mesa/LocalRemedio")
		GerenciadorAla.remedio_atual.reparent(local)
		GerenciadorAla.remedio_atual.position = Vector2.ZERO

func _alternar(mostrar: Node, esconder: Node) -> void:
	esconder.hide()
	esconder.process_mode = Node.PROCESS_MODE_DISABLED
	mostrar.show()
	mostrar.process_mode = Node.PROCESS_MODE_INHERIT

func _on_botao_ir_consultorio_pressed() -> void:
	ir_para_consultorio()

func _on_botao_ir_medicacao_pressed() -> void:
	ir_para_ala()
