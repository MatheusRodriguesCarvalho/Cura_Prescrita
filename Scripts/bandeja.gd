class_name Bandeja
extends Node2D

const MAX_INGREDIENTES = 8

@onready var area: Area2D = $Area2D


func _ready() -> void:
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

func _process(delta: float) -> void:
	pass

func get_ingredientes() -> Array[IngredienteInstancia]:
	var resultado: Array[IngredienteInstancia] = []
	for filho in get_children():
		if filho is IngredienteInstancia:
			resultado.append(filho)
	return resultado

func esta_cheia() -> bool:
	return get_ingredientes().size() >= MAX_INGREDIENTES

func adicionar(instancia: IngredienteInstancia) -> bool:
	if esta_cheia():
		return false
	instancia.reparent(self)
	instancia.position = Vector2.ZERO
	return true

func calcular_proporcoes() -> Dictionary:
	var itens := get_ingredientes()
	if itens.is_empty():
		return {}
	
	var contagem: Dictionary = {}
	for item in itens:
		contagem[item.ingrediente] = contagem.get(item.ingrediente, 0) + 1
	
	var proporcoes: Dictionary = {}
	for ingrediente in contagem.keys():
		proporcoes[ingrediente] = snappedf(float(contagem[ingrediente]) / itens.size() * 100.0, 0.1)
	return proporcoes

func esvaziar() -> void:
	for filho in get_ingredientes():
		filho.queue_free()

func _on_mouse_entered() -> void:
	TooltipInfo.mostrar.emit(_texto_tooltip)

func _on_mouse_exited() -> void:
	TooltipInfo.esconder.emit()

func _texto_tooltip() -> String:
	var proporcoes := calcular_proporcoes()
	if proporcoes.is_empty():
		return "Bandeja Vazia"
	var linhas := ["Bandeja: "]
	for ingrediente in proporcoes.keys():
		linhas.append(" %s: %.1f%%" % [ingrediente.nome, proporcoes[ingrediente]])
	return "/n".join(linhas)
