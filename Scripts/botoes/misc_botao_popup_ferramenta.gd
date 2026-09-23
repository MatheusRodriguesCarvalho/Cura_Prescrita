extends Control

@onready var label_resultado: Label = $Resultado
var ativo: bool = false

func _ready() -> void:
	hide()
	PopupFerramentas.solicitado.connect(_mostrar)
	PopupFerramentas.escondido.connect(_esconder)

func _process(_delta: float) -> void:
	if ativo:
		global_position = get_viewport().get_mouse_position() + Vector2(20, -20)

func _mostrar(texto: String) -> void:
	label_resultado.text = texto
	ativo = true
	show()

func _esconder() -> void:
	ativo = false
	hide()
