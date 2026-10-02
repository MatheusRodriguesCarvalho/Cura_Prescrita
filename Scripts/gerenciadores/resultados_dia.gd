extends Control

@onready var label_pacientes: Label = $VBox/LabelPacientes

@onready var label_diagnosticos: Label = $VBox/SecaoDiagnosticos/LabelDiagnosticos
@onready var label_subtotal_diagnostico: Label = $VBox/SecaoDiagnosticos/LabelSubtotalDiagnosticos

@onready var label_temperatura: Label = $VBox/SecaoMedicoes/LabelTemperatura
@onready var label_pressao: Label = $VBox/SecaoMedicoes/LabelPressao
@onready var label_saturacao: Label = $VBox/SecaoMedicoes/LabelSaturacao
@onready var label_subtotal_medicao: Label = $VBox/SecaoMedicoes/LabelSubtotalMedicao

@onready var label_remedios: Label = $VBox/SecaoRemedios/LabelRemedios
@onready var label_subtotal_remedio: Label = $VBox/SecaoRemedios/LabelSubtotalRemedios

@onready var lista_detalhes: VBoxContainer = $VBox/ScrollDetalhes/ListaDetalhes

@onready var label_meta: Label = $VBox/LabelMeta
@onready var label_total: Label = $VBox/LabelTotal
@onready var botao_continuar: Button = $VBox/BotaoContinuar

var resumo: Dictionary
var passou_da_meta: bool


func _ready() -> void:
	resumo = GerenciadorPacientes.gerar_resumo_dia()
	var meta: float = GerenciadorPacientes.meta_do_dia()
	
	passou_da_meta = resumo["pontos_total"] >= meta
	
	_popular(meta)
	botao_continuar.pressed.connect(_on_continuar_pressed)

func _popular(meta: float) -> void:
	label_pacientes.text = "Pacientes atendidos: %d / %d chamados" % [resumo["pacientes_atendidos"], resumo["pacientes_chamados"]]
	
	label_diagnosticos.text = "Diagnósticos corretos: %d / %d" % [resumo["diagnosticos_corretos"], resumo["diagnosticos_total"]]
	label_subtotal_diagnostico.text = "Subtotal: %.0f pts" % resumo["pontos_diagnostico"]
	
	var med: Dictionary = resumo["medicoes"]
	label_temperatura.text = "Temperatura: %d/%d corretas" % [med["temperatura"]["corretas"], med["temperatura"]["total"]]
	label_pressao.text = "Pressão: %d/%d corretas" % [med["pressao"]["corretas"], med["pressao"]["total"]]
	label_saturacao.text = "Saturação: %d/%d corretas" % [med["saturacao"]["corretas"], med["saturacao"]["total"]]
	label_subtotal_medicao.text = "Subtotal: %.0f pts" % resumo["pontos_medicao"]
	
	label_remedios.text = "Remédios corretos: %d / %d" % [resumo["remedios_corretos"], resumo["remedios_total"]]
	label_subtotal_remedio.text = "Subtotal: %.0f pts" % resumo["pontos_remedio"]
	
	label_meta.text = "Meta do dia: %.0f pts — %s" % [meta, "Atingida" if passou_da_meta else "Não atingida"]
	label_total.text = "TOTAL: %.0f pts" % resumo["pontos_total"]
	
	for filho in lista_detalhes.get_children():
		filho.queue_free()
	for item in resumo["detalhes"]:
		var linha := Label.new()
		var status := "✓" if item["acertou"] else "✗"
		linha.text = "%s Protocolo %s — Real: %s | Digitado: %s" % [status, item["protocolo"], item["doenca_real"], item["diagnostico_digitado"]]
		lista_detalhes.add_child(linha)




func _on_continuar_pressed() -> void:
	if passou_da_meta:
		get_tree().change_scene_to_file("res://Scenes/casa.tscn")
	else:
		get_tree().change_scene_to_file("res://Scenes/menu_inicial.tscn")
