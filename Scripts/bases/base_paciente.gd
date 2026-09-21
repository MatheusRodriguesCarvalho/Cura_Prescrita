class_name Paciente
extends Node2D

@export_category("Cadastro")
## Identificação única do paciente
@export var protocolo: String
## Nome do Paciente
@export var nome: String
## Idade do Paciente
@export_range(18, 100) var idade: int

@export_category("Cadastro (cosmético)")
@export var tipo_sanguineo: String = "AB+"
@export var implantes: String = "Leitor neural / Joelho esquerdo articulado."
@export var transplantes: String = "Figado AB+ / Córnea direita."

@export_group("Condição")
## Doença associada a este paciente, sorteada da lista de doenças possíveis.
@export var doenca: Doenca

@export var med_pressao_sistolica: float
@export var med_pressao_diastolica: float
@export var med_temperatura: float
@export var med_saturacao: float

@export_group("Dialogo Filler")
@export var falas_vida_perguntas: Array[String] = [
	"Como foi sua semana?",
	]
@export var falas_vida_respostas: Array[String] = [
	"Foi bem Ruim, no começo da semana eu acabei tropeçando do meio-fio",
]
@export var menu_dialogo: Control


@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D


var leitura_registradas: Dictionary = {}
var ficha_impressa: bool = false



func _ready() -> void:
	area.input_event.connect(_on_input_event)

func _on_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		menu_dialogo.abrir(self)

func fala_vida_aleatoria() -> Dictionary:
	if falas_vida_perguntas.is_empty():
		return {}
	var indice := randi() % falas_vida_perguntas.size()
	return {"pergunta": falas_vida_perguntas[indice], "resposta": falas_vida_respostas[indice]}

func apliar_doenca(doenca_sorteada: Doenca) -> void:
	doenca = doenca_sorteada
	med_pressao_sistolica = _variar(doenca.med_pressao_sistolica)
	med_pressao_diastolica = _variar(doenca.med_pressao_diastolica)
	med_temperatura = _variar(doenca.med_temperatura)
	med_saturacao = _variar(doenca.med_saturacao)

func _variar(valor: float, margem: float = 0.05) -> float:
	var variacao := valor * margem
	return valor + randf_range(-variacao, variacao)
