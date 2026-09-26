# TooltipUI.gd, no Control dentro do CanvasLayer da Ala
extends Control

@export var estilo_ferramenta: EstiloLabel
@export var estilo_item: EstiloLabel
@export var estilo_porcent: EstiloLabel

@onready var fundo: PanelContainer = $Fundo
@onready var label: Label = $Fundo/Label

var id_atual := 0
var ativo: bool = false

func _ready() -> void:
	hide()
	
	modulate.a = 0.0
	TooltipInfo.mostrar.connect(_mostrar)
	TooltipInfo.esconder.connect(_esconder)


func _process(_delta: float) -> void:
	if ativo:
		global_position = get_global_mouse_position() + Vector2(16, 16)

func _mostrar(texto: String, estilo: String) -> void:
	id_atual += 1
	label.text = texto
	ativo = true
	
	var estilo_escolhido: EstiloLabel = _escolher_estilo(estilo)
	if estilo_escolhido:
		estilo_escolhido.aplicar(fundo, label)
	
	show()
	create_tween().tween_property(self, "modulate:a", 1.0, 0.15)


func _esconder() -> void:
	id_atual += 1
	var meu_id := id_atual
	ativo = false
	
	##create_tween().tween_property(self, "modulate:a", 0.0, 0.3)
	##hide()
	
	var tween := create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		if id_atual == meu_id:
			hide()
	)


func _escolher_estilo(estilo: String) -> EstiloLabel:
	match estilo:
		"ferramenta": return estilo_ferramenta
		"item": return estilo_item
		"porcent": return estilo_porcent
	return estilo_item  # fallback
