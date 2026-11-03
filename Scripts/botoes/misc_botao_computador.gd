extends Node2D

@export var ficha: Control
@export var duracao_ligar := 1.2

@onready var sprite_pc: Sprite2D = $Computador2D
@onready var area_clique: Area2D = $Area2D

@onready var sprite_desligar: Sprite2D = $BotaoDesligar/Sprite2D
@onready var area_desligar: Area2D = $BotaoDesligar/Area2D

var _piscando := false
var _tween_piscar: Tween
var ligado := false
var _tween_ligar: Tween


func _ready() -> void:
	area_clique.input_event.connect(_on_area_clique_input_event)
	area_desligar.input_event.connect(_on_area_desligar_input_event)
	
	GerenciadorAla.remedio_entregue.connect(_on_remedio_entregue)
	GerenciadorTempo.tempo_atualizado.connect(_on_tempo_atualizado)


func _on_area_clique_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if not ligado:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		ficha.show()
		GerenciadorTempo.registrar_acao(1.0)

func abrir_ficha() -> void:
	ficha.show()

func _on_remedio_entregue(_var: bool) -> void:
	ficha.limpar_informacoes()

func _on_tempo_atualizado(_atual: float, _total: float) -> void:
	var passou := GerenciadorTempo.passou_do_expediente()
	if passou and not _piscando:
		_iniciar_piscar()
	elif not passou and _piscando:
		_parar_piscar()


## --- ANIMAÇÃO COMPUTADOR ---
func desligar() -> void:
	ligado = false
	if _tween_ligar:
		_tween_ligar.kill()
	sprite_pc.frame = 0

func ligar() -> void:
	if ligado or not is_inside_tree():
		return
	ligado = true
	var ultimo := sprite_pc.hframes * sprite_pc.vframes - 1
	if _tween_ligar:
		_tween_ligar.kill()
	_tween_ligar = create_tween()
	_tween_ligar.tween_method(func(q: float): sprite_pc.frame = int(q), 0.0, float(ultimo) + 0.99, duracao_ligar)
	# GerenciadorAudio.tocar("computador_ligar")  # se tiver um som para isso


## --- ANIMAÇÃO BOTAO ---
func _iniciar_piscar() -> void:
	_piscando = true
	_tween_piscar = create_tween().set_loops()
	_tween_piscar.tween_property(sprite_desligar, "modulate:a", 0.3, 0.5)
	_tween_piscar.tween_property(sprite_desligar, "modulate:a", 1.0, 0.5)

func _parar_piscar() -> void:
	_piscando = false
	if _tween_piscar:
		_tween_piscar.kill()
	sprite_desligar.modulate.a = 1.0


func _on_area_desligar_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_on_botao_desligar_pressed()

func _on_botao_desligar_pressed() -> void:
	if not GerenciadorTempo.passou_do_expediente():
		return
	_encerrar_dia()

func _encerrar_dia() -> void:
	GerenciadorTempo.encerrar_fase()
	## get_tree().change_scene_to_file("res://Scenes/resultados_dia.tscn")
