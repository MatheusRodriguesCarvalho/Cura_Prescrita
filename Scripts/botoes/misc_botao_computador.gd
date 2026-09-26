extends Node2D

@onready var ficha: Control = $"../../../../CanvasLayer/FichaPaciente"
@onready var area_clique: Area2D = $Area2D

@onready var sprite_desligar: Sprite2D = $BotaoDesligar/Sprite2D
@onready var area_desligar: Area2D = $BotaoDesligar/Area2D

var _piscando := false
var _tween_piscar: Tween


func _ready() -> void:
	area_clique.input_event.connect(_on_area_clique_input_event)
	
	area_desligar.input_event.connect(_on_area_desligar_input_event)
	GerenciadorTempo.tempo_atualizado.connect(_on_tempo_atualizado)

func _on_area_clique_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		ficha.show()

func _on_tempo_atualizado(_atual: float, _total: float) -> void:
	var passou := GerenciadorTempo.passou_do_expediente()
	if passou and not _piscando:
		_iniciar_piscar()
	elif not passou and _piscando:
		_parar_piscar()

func _iniciar_piscar() -> void:
	_piscando = true
	_tween_piscar = create_tween().set_loops()
	_tween_piscar.tween_property(sprite_desligar, "modulate:a", 0.3, 0.5)
	_tween_piscar.tween_property(sprite_desligar, "modulate:a", 1.0, 0.5)

func _parar_piscar() -> void:
	_piscando = false
	if _tween_piscar:
		_tween_piscar.kill()
	sprite_desligar.modulate.a = 1.0

func _on_area_desligar_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_botao_desligar_pressed()

func _on_botao_desligar_pressed() -> void:
	if not GerenciadorTempo.passou_do_expediente():
		return
	_encerrar_dia()

func _encerrar_dia() -> void:
	GerenciadorTempo.encerrar_fase()
	get_tree().change_scene_to_file("res://Scenes/casa.tscn")
