extends Node2D

@onready var botao_consultorio: Button = $CanvasLayer/Control/BotaoConsultorio


func _ready() -> void:
	
	botao_consultorio.pressed.connect(_on_botao_consultorio_pressed)

func _on_botao_consultorio_pressed() -> void:
	GerenciadorPacientes.avancar_fase()
	get_tree().change_scene_to_file("res://Scenes/consultorio.tscn")
