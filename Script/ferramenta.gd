## Representa uma ferramenta de diagnóstico usada no paciente
class_name Ferramenta
extends Node2D

enum Tipo { TEMPERATURA, SATURACAO, PRESSAO }

## Define qual medição esta ferramenta específica realiza.
@export var tipo: Tipo

## Ícone/sprite da ferramenta, exibido em cena.
@onready var sprite: Sprite2D = $Sprite2D


## Realiza a medição sobre o paciente informado e retorna o resultado
## já formatado para exibição (ex: "37.8 °C", "96%", "118/76 mmHg").
func medir(paciente: Paciente) -> String:
	match tipo:
		Tipo.TEMPERATURA:
			return "%.1f °C" % paciente.med_temperatura
		Tipo.SATURACAO:
			return "%.0f%%" % paciente.med_saturacao
		Tipo.PRESSAO:
			return "%.0f/%.0f mmHg" % [paciente.med_pressao_sistolica, paciente.med_pressao_diastolica]
	return "—"

func _usar_no_paciente(ferramenta: Ferramenta, paciente: Paciente) -> void:
	var resultado = ferramenta.medir(paciente)
	## label_resultado.text = resultado
