extends Node2D

@onready var area: Area2D = $Area2D
@onready var gaveta: Node2D = $"."
@onready var sprite: Sprite2D = $Gaveta2D

var aberto: bool = true


func _ready() -> void:
	area.input_event.connect(_on_area_clique_input_event)

func _on_area_clique_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_interagir()

func _interagir() -> void:
	if aberto:
		aberto = false
		sprite.frame = 1
		gaveta.position.y = gaveta.position.y + 150
	else:
		aberto = true
		sprite.frame = 0
		gaveta.position.y = gaveta.position.y - 150
