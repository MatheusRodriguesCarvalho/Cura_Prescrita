extends Node2D

@export var ingrediente: Ingrediente

@onready var  area: Area2D = $Area2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	area.input_event.connect(_on_input_event)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

func _on_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_spawnar_instancia()

func _spawnar_instancia() -> void:
	var cena := preload("res://Scenes/IngredienteInstancia.tscn")
	var instancia: IngredienteInstancia = cena.instantiate()
	get_tree().current_scene.add_child(instancia)
	instancia.global_position = global_position
	instancia.ingrediente = ingrediente
	instancia.iniciar_arasto()

func _on_mouse_entered() -> void:
	TooltipInfo.mostrar.emit("%s/n%s" % [ingrediente.nome, ingrediente.descricao])

func _on_mouse_exited() -> void:
	TooltipInfo.esconder.emit()
