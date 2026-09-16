class_name Bandeja
extends Node2D

const MAX_INGREDIENTES = 8
const TAMANHO_SLOT := Vector2(32, 32)
const COLUNAS := 4

var conteudo: Dictionary = {}

@onready var area: Area2D = $Area2D

func _ready() -> void:
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

func total_ingredientes() -> int:
	var total := 0
	for quantidade in conteudo.values():
		total += quantidade
	return total

func adicionar(ingrediente: Ingrediente) -> bool:
	if ingrediente == null or total_ingredientes() >= MAX_INGREDIENTES:
		return false
	
	var indice := total_ingredientes()
	conteudo[ingrediente] = conteudo.get(ingrediente, 0) + 1
	_criar_icone_visual(ingrediente, indice)
	return true

func _criar_icone_visual(ingrediente: Ingrediente, indice: int) -> void:
	var icone := Sprite2D.new()
	icone.texture = ingrediente.textura
	icone.scale = Vector2(0.1, 0.1)
	
	icone.position = Vector2(indice % COLUNAS, indice / COLUNAS) * TAMANHO_SLOT
	add_child(icone)

func calcular_proporcoes() -> Dictionary:
	var total := total_ingredientes()
	if total == 0:
		return {}
	
	var proporcoes: Dictionary = {}
	for ingrediente in conteudo.keys():
		proporcoes[ingrediente] = snappedf(float(conteudo[ingrediente]) / total * 100.0, 0.1)
	return proporcoes

func esvaziar() -> void:
	conteudo.clear()
	for filho in get_children():
		if filho is Sprite2D:
			filho.queue_free()

func _on_mouse_entered() -> void:
	var texto := _texto_tooltip()
	TooltipInfo.mostrar.emit(texto)

func _on_mouse_exited() -> void:
	TooltipInfo.esconder.emit()

func _texto_tooltip() -> String:
	var proporcoes := calcular_proporcoes()
	if proporcoes.is_empty():
		return "Bandeja Vazia"
	var linhas := ["Bandeja: "]
	
	## TODO VERIFICAR PORQUE NÃO TEM ACESSO AO NOME DO INGREDIENTE
	for ingrediente in proporcoes.keys():
		linhas.append(" %s: %.1f%%" % [ingrediente.nome, proporcoes[ingrediente]])
	return "\n".join(linhas)
