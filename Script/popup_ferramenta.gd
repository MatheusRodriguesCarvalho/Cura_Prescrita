extends PanelContainer

@onready var label_resultado: Label = $LabelResultado

func _ready() -> void:
	hide()
	PopupFerramentas.solicitado.connect(_mostrar)
	PopupFerramentas.escondido.connect(hide)

func _mostrar(resultado: String) -> void:
	label_resultado.text = resultado
	show()
