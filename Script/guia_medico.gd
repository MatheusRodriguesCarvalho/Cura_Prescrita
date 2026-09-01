extends Control

@onready var pagina_sumario: Control = $Painel
@onready var pagina_regras: Control = $Painel
@onready var pagina_doencas: Control = $Painel

@onready var lista_doencas_ui: VBoxContainer = $Painel
@onready var campo_busca: LineEdit = $Painel
@onready var painel_detalhe: Panel = $Painel

func abrir() -> void:
	show()
	_mostrar_pagina(pagina_sumario)

func fechar() -> void:
	hide()

func _mostrar_pagina(pagina: Control) -> void:
	pagina_doencas.hide()
	pagina_regras.hide()
	pagina_sumario.hide()
	pagina.show()

func _on_botao_doencas_pressed() -> void:
	_mostrar_pagina(pagina_doencas)
	_popular_doencas()

func _on_botao_voltar_pressed() -> void:
	_mostrar_pagina(pagina_sumario)

func _popular_doencas(filtro: String = "") -> void:
	for filho in lista_doencas_ui.get_children():
		filho.queue_free()
	
	var ativas := GerenciadorPacientes.doencas_ativas()
	ativas.sort_custom(func(a, b):
		return GerenciadorPacientes.doencas_desbloqueadas[a.id] < GerenciadorPacientes.doencas_desbloqueadas[b.id]
	)
	
	var fase_anterior = -1
	for doenca in ativas:
		if not _doenca_corresponde_filtro(doenca, filtro):
			continue
		
		var fase: int = GerenciadorPacientes.doencas_desbloqueadas[doenca.id]
		if fase != fase_anterior:
			var cabecalho := Label.new()
			cabecalho.text = "- Fase %d -" % fase
			lista_doencas_ui.add_child(cabecalho)
			fase_anterior = fase
		
		var botao := Button.new()
		botao.text = doenca.nome_popular[0] if not doenca.nome_popular.is_empty() else doenca.nome
		botao.pressed.connect(_mostrar_detalhe_doenca.bind(doenca))
		lista_doencas_ui.add_child(botao)

func _doenca_corresponde_filtro(doenca: Doenca, filtro: String) -> bool:
	if filtro == "":
		return true
	var alvo := filtro.to_lower()
	if alvo in doenca.nome.to_lower():
		return true
	for apelido in doenca.nome_popular:
		if alvo in apelido.to_lower():
			return true
	return false

func _on_campo_busca_text_changed(novo_texto: String) -> void:
	_popular_doencas()

func _mostrar_detalhe_doenca(doenca: Doenca) -> void:
	var nomes_populares := ", ".join(doenca.nome_popular) if not doenca.nome_popular.is_empty() else "—"
	painel_detalhe.get_node("Nome").text = doenca.nome
	painel_detalhe.get_node("NomePopular").text = "Também conhecida como: " + nomes_populares
	painel_detalhe.get_node("Categoria").text = doenca.categoria
	painel_detalhe.get_node("Risco").text = "Risco: " + ["Baixo", "Moderado", "Alto"][doenca.risco - 1]
	painel_detalhe.get_node("Descricao").text = doenca.descricao
	painel_detalhe.get_node("Sintomas").text = "Sintomas: " + ", ".join(doenca.sintomas)
	
	var f_sist := doenca.faixa_pressao_sistolica()
	var f_diast := doenca.faixa_pressao_diastolica()
	var f_temp := doenca.faixa_temperatura()
	var f_sat := doenca.faixa_saturacao()
	
	painel_detalhe.get_node("Pressao").text = "Pressão: %.0f–%.0f / %.0f–%.0f mmHg" % [f_sist.x, f_sist.y, f_diast.x, f_diast.y]
	painel_detalhe.get_node("Temperatura").text = "Temperatura: %.1f–%.1f °C" % [f_temp.x, f_temp.y]
	painel_detalhe.get_node("Saturacao").text = "Saturação: %.0f–%.0f%%" % [f_sat.x, f_sat.y]
