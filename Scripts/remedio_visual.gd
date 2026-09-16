class_name RemedioVisual
extends Node2D

var proporcoes: Dictionary = {}
enum Estado { PARADA, SEGURANDO }
var estado: Estado = Estado.PARADA

@onready var area: Area2D = $Area2D
@onready var botao_produzir: TextureButton = $CanvasLayer/BotaoProduzir/Produzir
@onready var bandeja: Bandeja = $AlaMedicacao/Mundo/Mesa/Bandeja

func _ready() -> void:
	top_level = true
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)
	area.input_event.connect(_on_input_event)
	
	botao_produzir.pressed.connect(_on_botao_produzir_pressed)

func _process(_delta: float) -> void:
	if estado == Estado.SEGURANDO:
		global_position = get_global_mouse_position()

func _on_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and estado == Estado.PARADA:
		estado = Estado.SEGURANDO

func _unhandled_input(event: InputEvent) -> void:
	if estado != Estado.SEGURANDO:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_soltar()

func _soltar() -> void:
	estado = Estado.PARADA
	var alvo := _buscar_alvo_sob_cursor()
	if alvo is Lixeira:
		queue_free()
	elif alvo is Paciente:
		GerenciadorAla.entregar_remedio(self, alvo)

func _buscar_alvo_sob_cursor() -> Node:
	var espaco := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	for resultado in espaco.intersect_point(params):
		var pai: Node = resultado.collider.get_parent()
		if pai is Lixeira or pai is Paciente or pai is Bandeja:
			return pai
	return null

func _on_botao_produzir_pressed() -> void:
	var proporcoes := bandeja.calcular_proporcoes()
	if proporcoes.is_empty():
		return
	
	## TODO continuar...

func _on_mouse_entered() -> void:
	TooltipInfo.mostrar.emit(_texto_tooltip())

func _on_mouse_exited() -> void:
	TooltipInfo.esconder.emit()

func _texto_tooltip() -> String:
	var linhas := ["Remédio:"]
	for ingrediente in proporcoes.keys():
		linhas.append("  %s: %.1f%%" % [ingrediente.nome, proporcoes[ingrediente]])
	return "\n".join(linhas)
