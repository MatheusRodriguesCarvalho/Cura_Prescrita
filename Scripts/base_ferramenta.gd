## Representa uma ferramenta de diagnóstico usada no paciente
class_name Ferramenta
extends Node2D

enum Tipo { TEMPERATURA, SATURACAO, PRESSAO }
enum Estado { PARADA, SEGURANDO, ANALISANDO , CONCLUIDO }
## Define qual medição esta ferramenta específica realiza.
@export var tipo: Tipo

@export var tempo_leitura: float = 1.5
@export var tempo_popup: float = 2.5
@export var custo_e_leitura: float = 5.0
@export var custo_e_manuseio: float = 1.0

var estado: Estado = Estado.PARADA
var posicao_original: Vector2
var paciente_alvo: Paciente = null
var tempo_decorrido: float = 0.0

## Ícone/sprite da ferramenta, exibido em cena.
@onready var area_clique: Area2D = $AreaClique
@onready var sprite: Sprite2D = $Sprite2D

signal medicao_concluida(tipo: Tipo, resultado: String)


func _ready() -> void:
	## top_level = true
	posicao_original = global_position
	area_clique.input_event.connect(_on_area_clique_input_event)

func _process(_delta: float) -> void:
	match estado:
		Estado.SEGURANDO:
			global_position = get_global_mouse_position()
			var paciente := _buscar_paciente_sob_cursor()
			if paciente:
				_iniciar_analise(paciente)
		Estado.ANALISANDO:
			global_position = get_global_mouse_position()
			_processar_analise(_delta)
		Estado.CONCLUIDO:
			global_position = get_global_mouse_position()

## --- Leitura e ações ---
func _on_area_clique_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed and estado == Estado.PARADA:
		_pegar()

func _unhandled_input(event: InputEvent) -> void:
	if estado == Estado.PARADA:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		_soltar()

func _pegar() -> void:
	estado = Estado.SEGURANDO
	GerenciadorTempo.registrar_acao(custo_e_manuseio)

func _soltar() -> void:
	PopupFerramentas.escondido.emit()
	estado = Estado.PARADA
	paciente_alvo = null
	var tween := create_tween()
	tween.tween_property(self, "global_position", posicao_original, 0.3)


## --- Buscas ---
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


## --- Analise ---
func _iniciar_analise(paciente: Paciente) -> void:
	estado = Estado.ANALISANDO
	paciente_alvo = paciente
	tempo_decorrido = 0.0
	PopupFerramentas.solicitado.emit("Analisando...")

func _processar_analise(delta: float) -> void:
	var paciente := _buscar_paciente_sob_cursor()
	if paciente != paciente_alvo:
		_cancelar_analise()
		return
	tempo_decorrido += delta
	if tempo_decorrido >= tempo_leitura:
		_concluir_analise()

func _cancelar_analise() -> void:
	estado = Estado.SEGURANDO
	paciente_alvo = null
	PopupFerramentas.escondido.emit()

func _concluir_analise() -> void:
	if not is_instance_valid(paciente_alvo):
		_cancelar_analise()
		return
	
	var resultado := medir(paciente_alvo)
	_registrar_no_paciente(paciente_alvo, resultado)
	medicao_concluida.emit(tipo, resultado)
	GerenciadorTempo.registrar_acao(custo_e_leitura)
	PopupFerramentas.solicitado.emit(resultado)
	estado = Estado.CONCLUIDO

func _registrar_no_paciente(paciente: Paciente, resultado: String) -> void:
	var chave := ""
	match tipo:
		Tipo.TEMPERATURA: chave = "Temperatura"
		Tipo.PRESSAO: chave = "Pressao"
		Tipo.SATURACAO: chave = "Saturacao"
	paciente.leitura_registradas[chave] = resultado


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
