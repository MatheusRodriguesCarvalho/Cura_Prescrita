extends Control

@onready var bandeja: Bandeja = $"../../../AlaMedicacao/Mundo/Mesa/Bandeja"
@onready var local_remedio: Marker2D = $"../../../AlaMedicacao/Mundo/Mesa/LocalRemedior"

func _on_botao_produzir_pressed() -> void:
	var proporcoes := bandeja.calcular_proporcoes()
	if proporcoes.is_empty():
		return
	
	var cena := preload("res://Scenes/RemedioVisual.tscn")
	var remedio: RemedioVisual = cena.instantiate()
	get_tree().current_scene.add_child(remedio)
	remedio.proporcoes = proporcoes
	remedio.global_position = local_remedio.global_position

	GerenciadorAla.remedio_atual = remedio
	bandeja.esvaziar()
