class_name Lixeira
extends Node2D

@onready var area: Area2D = $Area2D

func _ready() -> void:
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	TooltipInfo.mostrar.emit("Lixeira — descarta ingredientes e remédios")

func _on_mouse_exited() -> void:
	TooltipInfo.esconder.emit()
