## mesmo que esteja "base_" no nome, esse script dunciona como o relogio ou computador
class_name Paciente
extends Node2D

## Identificação única do paciente, preenchida via apresentar().
var protocolo: String
var nome: String
var idade: int
var tipo_sanguineo: String
var implantes: String
var transplantes: String

## Doença associada a este paciente, sorteada da lista de doenças possíveis.
var doenca: Doenca

var med_pressao_sistolica: float
var med_pressao_diastolica: float
var med_temperatura: float
var med_saturacao: float
var receita_cura: Dictionary

var falas_vida_perguntas: Array[String] = []
var falas_vida_respostas: Array[String] = []

@onready var sprite: Sprite2D = $Sprite2D
@onready var area: Area2D = $Area2D
@onready var collision_shape: CollisionShape2D = $Area2D/CollisionShape2D

@onready var menu_dialogo: Control = $"../../../CanvasLayer/MenuDialogo"

var leitura_registradas: Dictionary = {}
var ficha_impressa: bool = false



func _ready() -> void:
	area.input_event.connect(_on_input_event)
	collision_shape.disabled = true
	hide()

func _on_input_event(_viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed:
		menu_dialogo.abrir(self)


## Preenche este paciente com os dados cadastrais fixos (DadosPaciente)
## e aplica a doença sorteada para o atendimento.
func apresentar(dados: DadosPaciente, doenca_sorteada: Doenca) -> void:
	protocolo = dados.protocolo
	nome = dados.nome
	idade = dados.idade
	tipo_sanguineo = dados.tipo_sanguineo
	implantes = dados.implantes
	transplantes = dados.transplantes
	sprite.texture = dados.textura
	falas_vida_perguntas = dados.falas_vida_perguntas
	falas_vida_respostas = dados.falas_vida_respostas
	
	leitura_registradas = {}
	ficha_impressa = false
	
	apliar_doenca(doenca_sorteada)
	collision_shape.disabled = false
	show()

## Esvazia o paciente ao final do atendimento, deixando-o pronto para
## o próximo apresentar().
func esvaziar() -> void:
	hide()
	collision_shape.disabled = true
	protocolo = ""
	doenca = null

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
	receita_cura = doenca.receita_cura

func _variar(valor: float, margem: float = 0.05) -> float:
	var variacao := valor * margem
	return valor + randf_range(-variacao, variacao)
