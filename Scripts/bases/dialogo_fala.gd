# fala_dialogo.gd (raiz PanelContainer)
extends PanelContainer

@onready var label_nome: Label = $Caixa/LabelNome
@onready var label_texto: Label = $Caixa/LabelTexto
var _saindo := false

var _entrada := 0.0
var _topo := 1.0



func configurar(quem: String, texto: String, estilo: EstiloFala) -> void:
	size_flags_horizontal = SIZE_SHRINK_END if estilo.lado == EstiloFala.Lado.DIREITA else SIZE_SHRINK_BEGIN
	label_texto.text = texto
	if estilo.estilo_balao:
		estilo.estilo_balao.aplicar(self, label_texto)
	label_nome.visible = estilo.estilo_nome != null
	if label_nome.visible:
		label_nome.text = quem
		estilo.estilo_nome.aplicar(PanelContainer.new(), label_nome)
	
	create_tween().tween_method(func(v: float): _entrada = v; _atualizar(), 0.0, 1.0, 0.2)


func dispensar() -> void:
	if _saindo: return
	_saindo = true
	var t := create_tween()
	t.tween_property(self, "modulate:a", 0.0, 0.25)
	t.tween_callback(queue_free)


func definir_alpha_topo(a: float) -> void:
	_topo = a
	_atualizar()

func _atualizar() -> void:
	modulate.a = _entrada * _topo
