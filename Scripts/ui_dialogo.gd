extends Control

@onready var label_nome: Label = $Campo/LabelNome
@onready var label_texto: Label = $Campo/LabelTexto

func _ready() -> void:
	hide()
	GerenciadorDialogos.falar.connect(_mostrar)

func _mostrar(quem: String, texto: String) -> void:
	label_nome.text = quem
	label_texto.text = texto
	show()
	await get_tree().create_timer(GerenciadorDialogos.tempo_exibicao).timeout
	hide()
