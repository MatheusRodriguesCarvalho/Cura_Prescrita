# TooltipUI.gd, no Control dentro do CanvasLayer da Ala.
# Cuida de DOIS elementos: o tooltip (segue o mouse) e o aviso (fixo, no lugar do node).
extends Control

@export var estilo_ferramenta: EstiloLabel
@export var estilo_item: EstiloLabel
@export var estilo_porcent: EstiloLabel

@export_group("Aviso")
## Node do aviso no canvas (irmão deste, NÃO filho). Precisa ter Fundo (PanelContainer) > Label.
@export var aviso: Control
@export var estilo_aviso: EstiloLabel
@export var aviso_duracao := 1.6

@onready var fundo: PanelContainer = $Fundo
@onready var label: Label = $Fundo/Label

var id_atual := 0
var ativo: bool = false
var _tween: Tween

var _aviso_fundo: PanelContainer
var _aviso_label: Label
var _aviso_x0 := 0.0
var _aviso_tween: Tween
var _aviso_tween_tremor: Tween


func _ready() -> void:
	hide()
	
	modulate.a = 0.0
	TooltipInfo.mostrar.connect(_mostrar)
	TooltipInfo.esconder.connect(_esconder)
	_preparar_aviso()


func _process(_delta: float) -> void:
	if ativo:
		global_position = get_global_mouse_position() + Vector2(16, 16)


## --- Tooltip ---
func _mostrar(texto: String, estilo: String) -> void:
	id_atual += 1
	label.text = texto
	ativo = true
	
	var estilo_escolhido: EstiloLabel = _escolher_estilo(estilo)
	if estilo_escolhido:
		estilo_escolhido.aplicar(fundo, label)
	
	show()
	_trocar_tween().tween_property(self, "modulate:a", 1.0, 0.15)


func _esconder() -> void:
	id_atual += 1
	var meu_id := id_atual
	ativo = false
	
	var tween := _trocar_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	tween.tween_callback(func():
		if id_atual == meu_id:
			hide()
	)


## Mata o tween anterior para que fade-in e fade-out nunca briguem pelo modulate.
func _trocar_tween() -> Tween:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	return _tween

func _escolher_estilo(estilo: String) -> EstiloLabel:
	match estilo:
		"ferramenta": return estilo_ferramenta
		"item": return estilo_item
		"porcent": return estilo_porcent
	return estilo_item  # fallback


## --- Aviso (fixo; emitido por TooltipInfo.aviso.emit("texto")) ---
func _preparar_aviso() -> void:
	if aviso == null:
		push_warning("TooltipUI: arraste o node do aviso para o campo 'Aviso' no Inspetor.")
		return
	_aviso_fundo = aviso.get_node("Fundo")
	_aviso_label = aviso.get_node("Fundo/Label")
	_aviso_x0 = _aviso_fundo.position.x
	aviso.modulate.a = 0.0
	aviso.hide()
	if estilo_aviso:
		estilo_aviso.aplicar(_aviso_fundo, _aviso_label)
	TooltipInfo.aviso.connect(_mostrar_aviso)


func _mostrar_aviso(texto: String) -> void:
	_aviso_label.text = texto
	aviso.show()
	
	if _aviso_tween:
		_aviso_tween.kill()
	if _aviso_tween_tremor:
		_aviso_tween_tremor.kill()
	
	## Entrada + permanência + saída
	aviso.modulate.a = 0.0
	_aviso_tween = create_tween()
	_aviso_tween.tween_property(aviso, "modulate:a", 1.0, 0.12)
	_aviso_tween.tween_interval(aviso_duracao)
	_aviso_tween.tween_property(aviso, "modulate:a", 0.0, 0.3)
	_aviso_tween.tween_callback(aviso.hide)
	
	## Tremidinha lateral para chamar atenção ao erro
	_aviso_fundo.position.x = _aviso_x0
	_aviso_tween_tremor = create_tween()
	for d in [8.0, -8.0, 5.0, -5.0, 0.0]:
		_aviso_tween_tremor.tween_property(_aviso_fundo, "position:x", _aviso_x0 + d, 0.04)
