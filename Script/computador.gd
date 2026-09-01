extends Control

@onready var campo_protocolo: LineEdit = $CampoProtolo
@onready var ficha: Control = $Ficha 
@onready var label_erro: Label = $LabelErro

func _on_campo_protocolo_text_submitter(_texto: String) -> void:
	_buscar_paciente()

func _buscar_paciente() -> void:
	var protocolo := campo_protocolo.text.strip_edges()
	var paciente := GerenciadorPacientes.busca_por_protocolo(protocolo)
	
	if paciente == null:
		label_erro. text = "Protocolo não encontrado"
		label_erro.visible = true
		ficha.visible = false
		return
	
	label_erro.visible = false
	ficha.visible = true
	_preencher_ficha(paciente)

func _preencher_ficha(paciente: Paciente) -> void:
	ficha.get_node("Nome").text = paciente.nome
	ficha.get_node("Idade").text = str(paciente.idade) + " anos"
	ficha.get_node("Doenca").text = paciente.doenca.nome
	ficha.get_node("Pressao").text = "%.0f/%.0f mmHg" % [paciente.med_pressao_sistolica, paciente.med_pressao_diastolica]
	ficha.get_node("Temperatura").text = "%.1f °C" % paciente.med_temperatura
	ficha.get_node("Saturacao").text = "%.0f%%" % paciente.med_saturacao
