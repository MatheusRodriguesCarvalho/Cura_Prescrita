class_name IngredienteItem
extends Node2D

@export var ingrediente: Ingrediente
@export var tempo_fade_normal: float = 0.3
@export var tempo_fade_bandeja: float = 0.12

enum Estado { PARADO, SEGURANDO }
var estado = Estado.PARADO
var posicao_original: Vector2

@onready var  area: Area2D = $Area2D
@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	## top_level = true
	posicao_original = global_position
	if ingrediente:
		sprite.texture = ingrediente.textura
	
	area.input_event.connect(_on_input_event)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

func _process(delta: float) -> void:
	if estado == Estado.SEGURANDO:
		global_position = get_global_mouse_position()

func _on_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and estado == Estado.PARADO:
		estado = Estado.SEGURANDO

func _unhandled_input(event: InputEvent) -> void:
	if estado != Estado.SEGURANDO:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_soltar()


func _soltar() -> void:
	print("Instancia: soltando")
	estado = Estado.PARADO
	var alvo := _buscar_alvo_sob_cursor()
	
	##TODO if alvo and alvo.adicionar(ingrediente):
	if alvo is Bandeja and alvo.adicionar(ingrediente):
		_fade_e_retorna(tempo_fade_bandeja)
	else:
		_fade_e_retorna(tempo_fade_normal)

func _fade_e_retorna(duracao: float) -> void:
	var tween := create_tween()
	tween.tween_property(sprite, "modulate:a", 0.0, duracao)
	tween.tween_callback(func(): global_position = posicao_original)
	tween.tween_property(sprite, "modulate:a", 1.0, duracao * 0.8)

func _buscar_alvo_sob_cursor() -> Node:
	print("Instancia: procurando alvo")
	var espaco := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	for resultado in espaco.intersect_point(params):
		var pai: Node = resultado.collider.get_parent()
		if pai is Bandeja:
			print("Instancia: alvo encontrado")
			return pai
	print("Instancia: alvo não encontrado")
	return null


func _on_mouse_entered() -> void:
	TooltipInfo.mostrar.emit("%s\n%s" % [ingrediente.nome, ingrediente.descricao])

func _on_mouse_exited() -> void:
	TooltipInfo.esconder.emit()
