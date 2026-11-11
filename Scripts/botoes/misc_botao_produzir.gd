extends Node2D

@onready var bandeja: Bandeja = $"../Bandeja"
@onready var local_remedio: Marker2D = $"../LocalRemedio"

@onready var area_clique: Area2D = $Area2D

func _ready() -> void:
	area_clique.input_event.connect(_on_area_clique_input_event)

func _on_area_clique_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		produzir()

func produzir() -> void:
	
	GerenciadorTempo.registrar_acao(5.0)
	GerenciadorAudio.tocar("remedio")
	GerenciadorTutorial.notificar("remedio_produzido")
	
	var quantidades := bandeja.obter_quantidades()
	if quantidades.is_empty():
		return
	
	var cena := preload("res://Scenes/RemedioVisual.tscn")
	var remedio: RemedioVisual = cena.instantiate()
	get_tree().current_scene.add_child(remedio)
	remedio.quantidades = quantidades
	remedio.global_position = local_remedio.global_position
	
	GerenciadorAla.remedio_atual = remedio
	bandeja.esvaziar()
