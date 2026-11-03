## Gerenciador do Guia Medico:
	## Controla o acesso às páginas
	## 
	## 

extends Control

@export var pagina_noticia: Control
@export var pagina_sumario: Control
@export var pagina_doenca: Control

var _ultima_pagina: Control
var _ultima_doenca: Doenca


func _ready() -> void:
	hide()
	pagina_sumario.doenca_selecionada.connect(_on_doenca_selecionada)

func abrir(do_inicio: bool = false) -> void:
	show()
	if do_inicio or _ultima_pagina == null:
		pagina_noticia.popular()
		_mostrar_pagina(pagina_noticia)
	elif _ultima_pagina == pagina_doenca and _ultima_doenca != null:
		_mostrar_pagina(pagina_doenca, false)
		pagina_doenca.mostrar(_ultima_doenca)
	elif _ultima_pagina == pagina_sumario:
		_mostrar_pagina(pagina_sumario, false)
		pagina_sumario.popular()
	else:
		pagina_noticia.popular()
		_mostrar_pagina(pagina_noticia, false)

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
	_ultima_doenca = doenca
	_mostrar_pagina(pagina_doenca)
	pagina_doenca.mostrar(doenca)

func _mostrar_pagina(pagina: Control, som: bool = true) -> void:
	if som:
		GerenciadorAudio.tocar("folear")
	pagina_noticia.hide()
	pagina_sumario.hide()
	pagina_doenca.hide()
	pagina.show()
	_ultima_pagina = pagina

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		fechar()
