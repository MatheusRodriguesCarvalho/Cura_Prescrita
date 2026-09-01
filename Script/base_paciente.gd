## 
class_name Paciente
extends Node2D

@export_category("Identificação")
## Identificação única do paciente
@export var protocolo: String
## Nome do Paciente
@export var nome: String
## Idade do Paciente
@export_range(18, 100) var idade: int

@export_group("Condição")
## Doença associada a este paciente, sorteada da lista de doenças possíveis.
@export var doenca: Doenca

@export var med_pressao_sistolica: float
@export var med_pressao_diastolica: float
@export var med_temperatura: float
@export var med_saturacao: float

@export_category("Identificação")
@export_multiline var dialogo_inicial: String = "dialogo que roda quando o paciente chega"


@onready var sprite: Sprite2D = $Sprite2D

func apliar_doenca(doenca_sorteada: Doenca) -> void:
	doenca = doenca_sorteada
	med_pressao_sistolica = _variar(doenca.med_pressao_sistolica)
	med_pressao_diastolica = _variar(doenca.med_pressao_diastolica)
	med_temperatura = _variar(doenca.med_temperatura)
	med_saturacao = _variar(doenca.med_saturacao)

func _variar(valor: float, margem: float = 0.05) -> float:
	var variacao := valor * margem
	return valor + randf_range(-variacao, variacao)
