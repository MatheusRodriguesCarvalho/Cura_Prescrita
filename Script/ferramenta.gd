## Representa uma ferramenta de diagnóstico usada no paciente
class_name Ferramenta
extends Node2D

enum Tipo { TEMPERATURA, SATURACAO, PRESSAO }
enum Estado { PARADA, SEGURANDO, LENDO }
## Define qual medição esta ferramenta específica realiza.
@export var tipo: Tipo

@export var tempo_leitura: float = 1.5
@export var tempo_popup: float = 2.5

var estado: Estado = Estado.PARADA
var posicao_original: Vector2

## Ícone/sprite da ferramenta, exibido em cena.
@onready var area_clique: Area2D = $AreaClique
@onready var sprite: Sprite2D = $Sprite2D
@onready var popup: PanelContainer = $Popup
@onready var label_resultado: Label = $Popup/LabelResultado

signal medicao_concluida(tipo: Tipo, resultado: String)

func _ready() -> void:
	## top_level = true
	posicao_original = global_position
	popup.hide()
	area_clique.input_event.connect(_on_area_clique_input_event)

func _process(_delta: float) -> void:
	if estado == Estado.SEGURANDO:
		global_position = get_global_mouse_position()

func _on_area_clique_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed and estado == Estado.PARADA:
			_pegar()

func _unhandled_input(event: InputEvent) -> void:
	if estado != Estado.SEGURANDO:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_soltar()

func _pegar() -> void:
	estado = Estado.SEGURANDO
	popup.hide()

func _soltar() -> void:
	var paciente := _buscar_paciente_sob_cursor()
	if paciente:
		_iniciar_leitura(paciente)
	else:
		_retornar()

func _buscar_paciente_sob_cursor() -> Paciente:
	var espaco := get_world_2d().direct_space_state
	var params := PhysicsPointQueryParameters2D.new()
	params.position = get_global_mouse_position()
	params.collide_with_areas = true
	params.collide_with_bodies = false
	
	for resultado in espaco.intersect_point(params):
		var colisor: Node = resultado.collider
		if colisor.get_parent() is Paciente:
			return colisor.get_parent()
	return null

func _iniciar_leitura(paciente: Paciente) -> void:
	estado = Estado.LENDO
	await get_tree().create_timer(tempo_leitura).timeout
	
	var resultado := medir(paciente)
	_mostrar_popup(resultado)
	
	## Aparentemente isso iria preencher a ficha automaticamente
	medicao_concluida.emit(tipo, resultado)
	
	await get_tree().create_timer(tempo_popup).timeout
	_retornar()

func _mostrar_popup(resultado: String) -> void:
	label_resultado.text = resultado
	popup.show()

func _retornar() -> void:
	popup.hide()
	estado = Estado.PARADA
	var tween := create_tween()
	tween.tween_property(self, "global_position", posicao_original, 0.3)


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
