extends Control

@onready var bandeja: Bandeja = $"../../../AlaMedicacao/Mundo/Mesa/Bandeja"
@onready var local_remedio: Marker2D = $"../../../AlaMedicacao/Mundo/Mesa/LocalRemedio"
@onready var botao: TextureButton = $"."



func _ready() -> void:
	botao.pressed.connect(_on_botao_produzir_pressed)
	

func _on_botao_produzir_pressed() -> void:
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
