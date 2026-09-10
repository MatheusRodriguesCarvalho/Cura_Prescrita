extends Node2D

@onready var ficha: Control = $"../../../CanvasLayer/FichaPaciente"
@onready var area_clique: Area2D = $Area2D

func _ready() -> void:
	area_clique.input_event.connect(_on_area_clique_input_event)

func _on_area_clique_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		ficha.show()
