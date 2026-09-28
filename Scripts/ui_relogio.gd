extends Node2D

@onready var ponteiro_horas: Sprite2D = $pHoras
@onready var ponteiro_minutos: Sprite2D = $pMinutos
@onready var area: Area2D = $Area2D

@export var offset_ponteiro_horas: float = 0.0
@export var offset_ponteiro_minutos: float = 0.0

func _ready() -> void:
	GerenciadorTempo.tempo_atualizado.connect(_atualizar_relogio)
	area.mouse_entered.connect(_on_mouse_entered)
	area.mouse_exited.connect(_on_mouse_exited)

## obsoleto
func _atualizar_relogio_anterior(atual: float, total: float) -> void:
	var hora_atual := GerenciadorTempo.hora_atual()
	
	var horas_mostrador := fmod(hora_atual, 24.0)
	var minutos := fmod(hora_atual, 1.0) * 60
	
	## print("Horas: ", horas_mostrador, " / Minutos ", minutos)
	
	ponteiro_minutos.rotation_degrees = minutos * 6 + offset_ponteiro_minutos
	ponteiro_horas.rotation_degrees = horas_mostrador * 30.0 + offset_ponteiro_horas


func _atualizar_relogio(atual: float, total: float) -> void:
	var hora_atual := _calcular_tempo()
	
	var horas_mostrador: float = hora_atual["hora"]
	var minutos: float = hora_atual["minuto"]
	
	ponteiro_minutos.rotation_degrees = minutos * 6 + offset_ponteiro_minutos
	ponteiro_horas.rotation_degrees = horas_mostrador * 30.0 + offset_ponteiro_horas


func _calcular_tempo() -> Dictionary:
	var tempos: Dictionary
	var hora_atual := GerenciadorTempo.hora_atual()
	
	var valor := fmod(hora_atual, 24.0)
	tempos["hora"] = valor
	valor = fmod(hora_atual, 1.0) * 60
	tempos["minuto"] = valor
	
	return tempos

func _texto_tooltip() -> String:
	var hora_atual := _calcular_tempo()
	
	var texto: String = "%.0f:%02.0f" % [hora_atual["hora"],hora_atual["minuto"]]
	return texto

func _on_mouse_entered() -> void:
	TooltipInfo.mostrar.emit(_texto_tooltip(), "porcent")

func _on_mouse_exited() -> void:
	TooltipInfo.esconder.emit()
