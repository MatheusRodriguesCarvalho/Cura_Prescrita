## Gerenciador do Guia Medico:
	## Controla o acesso às páginas
	## 
	## 

extends Control

@onready var pagina_noticia: Control = $PainelPaginas/PaginaNoticias
@onready var pagina_sumario: Control = $PainelPaginas/SumarioDoencas
@onready var pagina_doenca: Control = $PainelPaginas/PaginaDoenca


func _ready() -> void:
	hide()
	pagina_sumario.doenca_selecionada.connect(_on_doenca_selecionada)

func abrir() -> void:
	show()
	pagina_noticia.popular()
	_mostrar_pagina(pagina_noticia)

func fechar() -> void:
	hide()

func abrir_sumario_doencas() -> void:
	_mostrar_pagina(pagina_sumario)
	pagina_sumario.popular()

func mostrar_pagina_noticias() -> void:
	_mostrar_pagina(pagina_noticia)

func mostrar_pagina_sumario() -> void:
	_mostrar_pagina(pagina_sumario)

func _on_doenca_selecionada(doenca: Doenca) -> void:
	_mostrar_pagina(pagina_doenca)
	pagina_doenca.mostrar(doenca)

func _mostrar_pagina(pagina: Control) -> void:
	pagina_noticia.hide()
	pagina_sumario.hide()
	pagina_doenca.hide()
	pagina.show()


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		fechar()
