extends Control


const CENA_MENU := "res://Scenes/menu_inicial.tscn"

@export var botao := Button


func _ready() -> void:
	botao.pressed.connect(_on_continuar_pressed)

func _on_continuar_pressed() -> void:
	get_tree().change_scene_to_file(CENA_MENU)
