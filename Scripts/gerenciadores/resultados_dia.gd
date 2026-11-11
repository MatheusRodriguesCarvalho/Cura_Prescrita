extends Control


@export var texto_resumo: RichTextLabel
@export var texto_detalhes: RichTextLabel
@export var label_meta: Label
@export var label_total: Label
@export var botao_continuar: Button

var resumo: Dictionary
var passou_da_meta: bool


func _ready() -> void:
	resumo = GerenciadorPacientes.gerar_resumo_dia()
	var meta: float = GerenciadorPacientes.meta_do_dia()
	## var meta: float = -1
	
	passou_da_meta = resumo["pontos_total"] >= meta
	
	_popular(meta)
	
	botao_continuar.text = "Próximo Dia" if passou_da_meta else "Retornar ao menu"
	botao_continuar.pressed.connect(_on_continuar_pressed)


func _popular(meta: float) -> void:
	var med: Dictionary = resumo["medicoes"]
	
	var t := "[font_size=26][color=#509070]Pacientes:[/color][/font_size] %d atendidos / %d chamados\n\n" % [
		resumo["pacientes_atendidos"], resumo["pacientes_chamados"]]
	
	t += _secao("Diagnósticos",
		["Corretos: %d / %d" % [resumo["diagnosticos_corretos"], resumo["diagnosticos_total"]]],
		resumo["pontos_diagnostico"])
	
	t += _secao("Medições", [
		"Temperatura: %d/%d" % [med["temperatura"]["corretas"], med["temperatura"]["total"]],
		"Pressão: %d/%d" % [med["pressao"]["corretas"], med["pressao"]["total"]],
		"Saturação: %d/%d" % [med["saturacao"]["corretas"], med["saturacao"]["total"]],
	], resumo["pontos_medicao"])
	
	t += _secao("Remédios",
		["Corretos: %d / %d" % [resumo["remedios_corretos"], resumo["remedios_total"]]],
		resumo["pontos_remedio"])
	
	texto_resumo.text = t
	
	var d := ""
	for item in resumo["detalhes"]:
		var cor := "#7fcf7f" if item["acertou"] else "#e07a7a"
		var marca := "✓" if item["acertou"] else "✗"
		d += "[color=%s]%s[/color] Protocolo %s\n> Doença: %s | Digitado: %s\n\n" % [
			cor, marca, item["protocolo"], item["doenca_real"], item["diagnostico_digitado"]]
	texto_detalhes.text = d
	
	label_meta.text = "Meta do dia: %.0f pts — %s" % [meta, "Atingida" if passou_da_meta else "Não atingida"]
	label_total.text = "Total: %.0f pts" % resumo["pontos_total"]


## Título em negrito, linhas recuadas e subtotal alinhado à direita.
func _secao(titulo: String, linhas: Array[String], subtotal: float) -> String:
	var s := "[font_size=26][color=#509070]%s[/color][/font_size]\n" % titulo
	for l in linhas:
		s += "    %s\n" % l
	s += "[right][color=#c9b458]Subtotal: %.0f pts[/color][/right]\n" % subtotal
	return s


func _on_continuar_pressed() -> void:
	if not passou_da_meta:
		GerenciadorPacientes.final_pendente = "ruim"
	elif GerenciadorPacientes.e_ultimo_dia():
		GerenciadorPacientes.final_pendente = "bom"
	get_tree().change_scene_to_file("res://Scenes/visual_novel.tscn")
