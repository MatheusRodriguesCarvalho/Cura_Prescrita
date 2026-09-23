extends Control

@onready var label_nome: Label = $DivPagina/NomeDoenca
@onready var label_descricao: Label = $DivPagina/DivPaginaScroll/VBoxContainer/Descricao
@onready var label_risco: Label = $DivPagina/DivPaginaScroll/VBoxContainer/Risco
@onready var label_id: Label = $DivPagina/DivPaginaScroll/VBoxContainer/Id
@onready var label_nome_popular: Label = $DivPagina/DivPaginaScroll/VBoxContainer/NomePopular
@onready var label_categoria: Label = $DivPagina/DivPaginaScroll/VBoxContainer/Categoria
@onready var label_sintomas: Label = $DivPagina/DivPaginaScroll/VBoxContainer/Sintomas
@onready var label_temperatura: Label = $DivPagina/DivPaginaScroll/VBoxContainer/Temperatura
@onready var label_pressao: Label = $DivPagina/DivPaginaScroll/VBoxContainer/Pressao
@onready var label_oxigenacao: Label = $DivPagina/DivPaginaScroll/VBoxContainer/Oxigenacao


func mostrar(doenca: Doenca) -> void:
	label_nome.text = doenca.nome
	label_descricao.text = doenca.descricao
	label_risco.text = "Risco: " + ["Não Preocupante", "Baixo", "Moderado", "Alto", "Grave"][doenca.risco - 1]
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


func _on_pbotao_voltar_pressed() -> void:
	get_parent().get_parent().mostrar_pagina_sumario()
