extends Control

@onready var pagina_regras: Control = $PainelPaginas/PaginaRegras
@onready var pagina_sumario: Control = $PainelPaginas/SumarioDoencas
@onready var pagina_doenca: Control = $PainelPaginas/PaginaDoenca

@onready var lista_doencas_ui: VBoxContainer = $PainelPaginas/SumarioDoencas/DivDoencas/Scroll/ListaDoencas
@onready var campo_busca: LineEdit = $PainelPaginas/SumarioDoencas/DivDoencas/DivBusca/CampoBusca
@onready var filtro_categoria: OptionButton = $PainelPaginas/SumarioDoencas/DivDoencas/DivBusca/FiltroCategoria

@onready var label_nome: Label = $PainelPaginas/PaginaDoenca/DivPagina/NomeDoenca
@onready var label_descricao : Label = $PainelPaginas/PaginaDoenca/DivPagina/DivPaginaScroll/VBoxContainer/Descricao
@onready var label_risco : Label = $PainelPaginas/PaginaDoenca/DivPagina/DivPaginaScroll/VBoxContainer/Risco
@onready var label_id : Label = $PainelPaginas/PaginaDoenca/DivPagina/DivPaginaScroll/VBoxContainer/Id
@onready var label_nome_popular : Label = $PainelPaginas/PaginaDoenca/DivPagina/DivPaginaScroll/VBoxContainer/NomePopular
@onready var label_categoria : Label = $PainelPaginas/PaginaDoenca/DivPagina/DivPaginaScroll/VBoxContainer/Categoria
@onready var label_sintomas : Label = $PainelPaginas/PaginaDoenca/DivPagina/DivPaginaScroll/VBoxContainer/Sintomas
@onready var label_temperatura : Label = $PainelPaginas/PaginaDoenca/DivPagina/DivPaginaScroll/VBoxContainer/Temperatura
@onready var label_pressao : Label = $PainelPaginas/PaginaDoenca/DivPagina/DivPaginaScroll/VBoxContainer/Pressao
@onready var label_oxigenacao : Label = $PainelPaginas/PaginaDoenca/DivPagina/DivPaginaScroll/VBoxContainer/Oxigenacao

func _ready() -> void:
	hide()
	campo_busca.text_submitted.connect(_on_campo_busca_submitted)
	filtro_categoria.item_selected.connect(_on_filtro_categoria_selected)

func abrir() -> void:
	show()
	_mostrar_pagina(pagina_regras)

func fechar() -> void:
	hide()

func _mostrar_pagina(pagina: Control) -> void:
	pagina_regras.hide()
	pagina_sumario.hide()
	pagina_doenca.hide()
	pagina.show()

func _on_rbotao_voltar_pressed() -> void:
	fechar()
	print("Retorne ao consultorio")

func _on_rbotao_ir_pressed() -> void:
	_abrir_sumario_doencas()
	print("Vá ao sumario de doenças")

func _on_dbotao_voltar_pressed() -> void:
	_mostrar_pagina(pagina_regras)
	print("Retorne à guia de Regras")

func _on_pbotao_voltar_pressed() -> void:
	_mostrar_pagina(pagina_sumario)
	print("Retorne ao sumario de doenças")

func _abrir_sumario_doencas() -> void:
	_mostrar_pagina(pagina_sumario)
	_preencher_filtro_categoria()
	_popular_doencas()

func _preencher_filtro_categoria() -> void:
	## TODO, erro POR CONTA DE QUE QUANDO APARECE PELA PRIMEIRA VEZ, O FALOR É NEGATIVO
	print("valor: ", filtro_categoria.selected)
	var categoria_atual := filtro_categoria.get_item_text(filtro_categoria.selected) if filtro_categoria.item_count > 0 else "Todas"
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
	
	var ativas := GerenciadorPacientes.doencas_ativas()
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
		botao.pressed.connect(_mostrar_detalhe_doenca.bind(doenca))
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

func _mostrar_detalhe_doenca(doenca: Doenca) -> void:
	_mostrar_pagina(pagina_doenca)
	
	label_nome.text = doenca.nome
	label_descricao.text = doenca.descricao
	label_risco.text = "Risco: " + ["Baixo", "Moderado", "Alto"][doenca.risco - 1]
	label_id.text = "ID: " + doenca.id
	label_nome_popular.text = "Também conhecida como: " + (", ".join(doenca.nome_popular) if not doenca.nome_popular.is_empty() else "—")
	label_categoria.text = "Categoria: " + doenca.categoria
	label_sintomas.text = "Sintomas: " + ", ".join(doenca.sintomas)
	
	var f_sist := doenca.faixa_pressao_sistolica()
	var f_diast := doenca.faixa_pressao_diastolica()
	var f_temp := doenca.faixa_temperatura()
	var f_sat := doenca.faixa_saturacao()
	
	label_temperatura.text = "Temperatura: %.1f–%.1f °C" % [f_temp.x, f_temp.y]
	label_pressao.text = "Pressão: %.0f–%.0f / %.0f–%.0f mmHg" % [f_sist.x, f_sist.y, f_diast.x, f_diast.y]
	label_oxigenacao.text = "Saturação: %.0f–%.0f%%" % [f_sat.x, f_sat.y]
