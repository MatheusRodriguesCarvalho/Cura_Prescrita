extends Node2D

@onready var ponteiro_horas: Sprite2D = $pHoras
@onready var ponteiro_minutos: Sprite2D = $pMinutos
@onready var area: Area2D = $Area2D

var _offset_horas: float
var _offset_minutos: float

func _ready() -> void:
	_offset_horas = ponteiro_horas.rotation_degrees
	_offset_minutos = ponteiro_minutos.rotation_degrees
	
	GerenciadorTempo.tempo_atualizado.connect(_atualizar_relogio)
	
	TooltipInfo.vincular(area, _texto_tooltip, "porcent")


func _atualizar_relogio(atual: float, total: float) -> void:
	var hora_fracionaria := fmod(GerenciadorTempo.hora_atual(), 24.0)
	var minutos := fmod(hora_fracionaria, 1.0) * 60.0
	
	ponteiro_minutos.rotation_degrees = minutos * 6.0 + _offset_minutos
	ponteiro_horas.rotation_degrees = hora_fracionaria * 30.0 + _offset_horas


func _texto_tooltip() -> String:
	var hora_fracionaria := fmod(GerenciadorTempo.hora_atual(), 24.0)
	var hora_inteira := int(hora_fracionaria)
	var minutos := int(fmod(hora_fracionaria, 1.0) * 60.0)
	
	return "%02d:%02d" % [hora_inteira, minutos]
