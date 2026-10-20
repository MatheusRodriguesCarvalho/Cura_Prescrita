## Bandeija
class_name Bandeja
extends Node2D

const MAX_INGREDIENTES = 8
const TAMANHO_SLOT := Vector2(16, 16)
const COLUNAS := 4
const LINHAS := ceili(float(MAX_INGREDIENTES) / COLUNAS)  ## 8 / 4 = 2

@export var deslocamento_grade := Vector2.ZERO

@onready var area: Area2D = $Area2D

## Dicionario de Ingredientes: que aponta para as quantidades. "boldo": 2...
var conteudo: Dictionary = {}


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
	icone.scale = Vector2(0.75, 0.75)
	
	## icone.position = Vector2(indice % COLUNAS, indice / COLUNAS) * TAMANHO_SLOT
	icone.position = _posicao_do_slot(indice)
	
	add_child(icone)

func _posicao_do_slot(indice: int) -> Vector2:
	var coluna := indice % COLUNAS
	var linha := indice / COLUNAS
	## Subtrai metade da grade (em slots) para centralizar no origem do nó.
	var centrado := Vector2(
		coluna - (COLUNAS - 1) / 2.0,
		linha - (LINHAS - 1) / 2.0
	)
	return centrado * TAMANHO_SLOT + deslocamento_grade


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
		if filho is Sprite2D and not filho.name == "Bandeja2D":
			filho.queue_free()

func obter_quantidades() -> Dictionary:
	return conteudo.duplicate()

func _on_mouse_entered() -> void:
	var texto := _texto_tooltip()
	TooltipInfo.mostrar.emit(texto, "porcent")

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
