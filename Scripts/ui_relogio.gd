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

func _atualizar_relogio(atual: float, total: float) -> void:
	var hora_atual := GerenciadorTempo.hora_atual()
	
	var horas_mostrador := fmod(hora_atual, 24.0)
	var minutos := fmod(hora_atual, 1.0) * 60
	
	## print("Horas: ", horas_mostrador, " / Minutos ", minutos)
	
	ponteiro_minutos.rotation_degrees = minutos * 6 + offset_ponteiro_minutos
	ponteiro_horas.rotation_degrees = horas_mostrador * 30.0 + offset_ponteiro_horas

func _calcular_tempo(tempo: float) -> Dictionary:
	
	var tempos: Dictionary
	
	var hora_atual := GerenciadorTempo.hora_atual()
	
	
	var horas_mostrador := fmod(hora_atual, 24.0)
	tempos.keys()
	
	var minutos := fmod(hora_atual, 1.0) * 60
	
	
	
	return

func _on_mouse_entered() -> void:
	TooltipInfo.mostrar.emit("teste", "porcent")

func _on_mouse_exited() -> void:
	TooltipInfo.esconder.emit()
