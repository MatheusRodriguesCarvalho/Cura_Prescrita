extends Control

signal doenca_selecionada(doenca: Doenca)

@onready var lista_doencas_ui: VBoxContainer = $DivDoencas/Scroll/ListaDoencas
@onready var campo_busca: LineEdit = $DivDoencas/DivBusca/CampoBusca
@onready var filtro_categoria: OptionButton = $DivDoencas/DivBusca/FiltroCategoria


func _ready() -> void:
	campo_busca.text_submitted.connect(_on_campo_busca_submitted)
	filtro_categoria.item_selected.connect(_on_filtro_categoria_selected)


func popular() -> void:
	_preencher_filtro_categoria()
	_popular_doencas()


func _preencher_filtro_categoria() -> void:
	var categoria_atual := "Todas"
	if filtro_categoria.item_count > 0 and filtro_categoria.selected >= 0:
		categoria_atual = filtro_categoria.get_item_text(filtro_categoria.selected)

	filtro_categoria.clear()
	filtro_categoria.add_item("Todas")
	var categorias := {}
	
	for doenca in GerenciadorPacientes.doencas_ativas():
		categorias[doenca.categoria] = true
	for categoria in categorias.keys():
		filtro_categoria.add_item(categoria)
	
	for i in filtro_categoria.item_count:
		if filtro_categoria.get_item_text(i) == categoria_atual:
			filtro_categoria.selected = i
			break


func _on_campo_busca_submitted(_texto: String) -> void:
	_popular_doencas()
	campo_busca.clear()


func _on_filtro_categoria_selected(_indice: int) -> void:
	_popular_doencas()


func _popular_doencas(filtro: String = "") -> void:
	for filho in lista_doencas_ui.get_children():
		filho.queue_free()
	
	var ativas: Array[Doenca] = GerenciadorPacientes.doencas_ativas()
	ativas.sort_custom(func(a, b):
		return GerenciadorPacientes.doencas_desbloqueadas[a.id] < GerenciadorPacientes.doencas_desbloqueadas[b.id]
	)
	
	var filtro_texto := campo_busca.text.strip_edges()
	var categoria_selecionada := filtro_categoria.get_item_text(filtro_categoria.selected)
	for doenca in ativas:
		if not _doenca_corresponde_filtro(doenca, filtro_texto, categoria_selecionada):
			continue
		
		var fase: int = GerenciadorPacientes.doencas_desbloqueadas[doenca.id]
		var botao := Button.new()
		botao.text = "%s - Dia %d" % [doenca.nome, fase]
		botao.pressed.connect(func(): doenca_selecionada.emit(doenca))
		lista_doencas_ui.add_child(botao)


func _doenca_corresponde_filtro(doenca: Doenca, filtro_texto: String, categoria_selecionada: String) -> bool:
	if categoria_selecionada != "Todas" and doenca.categoria != categoria_selecionada:
		return false
	if filtro_texto == "":
		return true
	var alvo := filtro_texto.to_lower()
	if alvo in doenca.nome.to_lower():
		return true
	for apelido in doenca.nome_popular:
		if alvo in apelido.to_lower():
			return true
	return false


func _on_dbotao_voltar_pressed() -> void:
	get_parent().get_parent().mostrar_pagina_noticias()
