class_name IngredienteInstancia
extends Node2D

var ingrediente: Ingrediente
enum Estado {PARADO, SEGURANDO}
var estado: Estado = Estado.PARADO

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D


func _ready() -> void:
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	if ingrediente:
		sprite.texture = ingrediente.textura

func _precess(_felta: float) -> void:
	if estado == Estado.SEGURANDO:
		global_position = get_global_mouse_position()

func iniciar_arrasto() -> void:
	top_level = true
	estado = Estado.SEGURANDO

func _unhendle_input(event: InputEvent) -> void:
	if estado != Estado.SEGURANDO:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_soltar()

func _soltar() -> void:
	estado = Estado.PARADO
	var alvo := _buscar_alvo_sob_cursor()
	if alvo is Bandeja and alvo.adicionar(self):
		return
	queue_free()

func _buscar_alvo_sob_cursor() -> Node:
	var espaco := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	for resultado in espaco.intersect_point(params):
		var pai: Node = resultado.collider.get_parent()
		if pai is Bandeja:
			return pai
	return null

func _on_mouse_entered() -> void:
	if ingrediente:
		TooltipInfo.mostrar.emit("%s/n%s", [ingrediente. nome, ingrediente.descricao])

func _on_mouse_exited() -> void:
	TooltipInfo.esconder.emit()
