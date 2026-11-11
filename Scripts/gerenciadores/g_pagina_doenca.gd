extends Control


@export var label_nome: Label
@export var texto: RichTextLabel

const RISCOS := ["Não Preocupante", "Baixo", "Moderado", "Alto", "Grave"]
const CORES_RISCO := ["#7fcf7f", "#b6d96a", "#e6c84a", "#e8964a", "#e07a7a"]
const TAMANHO_FONT := 24

func mostrar(doenca: Doenca) -> void:
	label_nome.text = doenca.nome
	
	var f_sist := doenca.faixa_pressao_sistolica()
	var f_diast := doenca.faixa_pressao_diastolica()
	var f_temp := doenca.faixa_temperatura()
	var f_sat := doenca.faixa_saturacao()
	
	var nomes_populares := ", ".join(doenca.nome_popular) if not doenca.nome_popular.is_empty() else "—"
	var risco_i := clampi(doenca.risco - 1, 0, RISCOS.size() - 1)
	
	var t := "[font_size=24]"
	t += "%s\n\n" % _esc(doenca.descricao)
	t += _linha("Risco", "[color=%s]%s[/color]" % [CORES_RISCO[risco_i], RISCOS[risco_i]])
	t += _linha("ID", _esc(doenca.id))
	t += _linha("Também conhecida como", _esc(nomes_populares))
	t += _linha("Categoria", _esc(doenca.categoria))
	
	t += "\n[b]Sintomas[/b]\n"
	for s in doenca.sintomas:
		t += "  • %s\n" % _esc(s)
	
	t += "\n[b]Medições esperadas[/b]\n"
	t += _linha("Temperatura", "%.1f–%.1f °C" % [f_temp.x, f_temp.y])
	t += _linha("Pressão", "%.0f–%.0f / %.0f–%.0f mmHg" % [f_sist.x, f_sist.y, f_diast.x, f_diast.y])
	t += _linha("Saturação", "%.0f–%.0f%%" % [f_sat.x, f_sat.y])
	
	t += "\n" + _linha("Receita", _esc(doenca.print_receita())) + "[/font_size]"
	
	texto.text = t


## "Rótulo: valor" com o rótulo em negrito.
func _linha(rotulo: String, valor: String) -> String:
	return "[b]%s:[/b] %s\n" % [rotulo, valor]

## Texto vindo dos recursos pode ter colchetes; sem isso o BBCode quebraria.
func _esc(s: String) -> String:
	return s.replace("[", "[lb]")


func _on_pbotao_voltar_pressed() -> void:
	get_parent().get_parent().mostrar_pagina_sumario()
