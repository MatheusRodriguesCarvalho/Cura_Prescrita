# TooltipUI.gd, no Control dentro do CanvasLayer da Ala
extends Control

@onready var label: Label = $Label
var ativo := false

func _ready() -> void:
	modulate.a = 0.0
	TooltipInfo.mostrar.connect(_mostrar)
	TooltipInfo.esconder.connect(_esconder)

func _process(_delta: float) -> void:
	if ativo:
		global_position = get_global_mouse_position() + Vector2(16, 16)

func _mostrar(texto: String) -> void:
	label.text = texto
	ativo = true
	create_tween().tween_property(self, "modulate:a", 1.0, 0.15)

func _esconder() -> void:
	ativo = false
	create_tween().tween_property(self, "modulate:a", 0.0, 0.3)
