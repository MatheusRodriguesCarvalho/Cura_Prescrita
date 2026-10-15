extends Control

@onready var label_nome: Label = $Campo/LabelNome
@onready var label_texto: Label = $Campo/LabelTexto

var id_atual := 0

func _ready() -> void:
	hide()
	GerenciadorDialogos.falar.connect(_mostrar)


func _mostrar(quem: String, texto: String) -> void:
	id_atual += 1
	var meu_id := id_atual
	label_nome.text = quem
	label_texto.text = texto
	show()
	await get_tree().create_timer(GerenciadorDialogos.tempo_exibicao, false).timeout
	## Só esconde se nenhuma fala mais nova tiver substituído esta.
	if id_atual == meu_id:
		hide()
