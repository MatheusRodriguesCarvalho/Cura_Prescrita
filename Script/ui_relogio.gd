extends Node2D

@export var hora_expediente_inicio: float = 9.0
@export var hora_expediente_fim: float = 17.0
@export var hora_extra: float = 7.0

@onready var ponteiro_horas: Sprite2D = $pHoras
@onready var ponteiro_minutos: Sprite2D = $pMinutos

@export var offset_ponteiro_horas: float = 0.0
@export var offset_ponteiro_minutos: float = 0.0


func _ready() -> void:
	GerenciadorTempo.tempo_atualizado.connect(_atualizar_relogio)

func _atualizar_relogio(atual: float, total: float) -> void:
	var progresso: float = 1.0 - (atual/total)
	var hora_maxima_possivel := hora_expediente_fim + hora_extra
	
	var hora_atual := hora_expediente_inicio + progresso * (hora_maxima_possivel - hora_expediente_inicio)
	
	var horas_mostrador := fmod(hora_atual, 24.0)
	var minutos := fmod(hora_atual, 1.0) * 60
	
	print("Horas: ", horas_mostrador, " / Minutos ", minutos)
	
	ponteiro_minutos.rotation_degrees = minutos * 6 + offset_ponteiro_minutos
	ponteiro_horas.rotation_degrees = horas_mostrador * 30.0 + offset_ponteiro_horas

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
