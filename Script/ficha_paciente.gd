extends Control

@onready var campo_protocolo: LineEdit = $FichaPaginas/ScrollContainer/VBoxContainer/CampoProtocolo

@onready var label_nome: Label = $FichaPaginas/ScrollContainer/VBoxContainer/PainelCadastro/Nome
@onready var label_idade: Label = $FichaPaginas/ScrollContainer/VBoxContainer/PainelCadastro/Idade
@onready var label_tipo_sanguineo: Label = $FichaPaginas/ScrollContainer/VBoxContainer/PainelCadastro/TipoSangue
@onready var label_implantes: Label = $FichaPaginas/ScrollContainer/VBoxContainer/PainelCadastro/Implantes
@onready var label_transplantes: Label = $FichaPaginas/ScrollContainer/VBoxContainer/PainelCadastro/Transplantes

@onready var campo_temperatura: LineEdit = $FichaPaginas/ScrollContainer/VBoxContainer/PainelQuadro/Temperatura
@onready var campo_pressao: LineEdit = $FichaPaginas/ScrollContainer/VBoxContainer/PainelQuadro/Pressao
@onready var campo_saturacao: LineEdit = $FichaPaginas/ScrollContainer/VBoxContainer/PainelQuadro/Saturacao
@onready var lista_sintomas: VBoxContainer = $FichaPaginas/ScrollContainer/VBoxContainer/PainelQuadro/Sintomas
@onready var campo_condicao: LineEdit = $FichaPaginas/ScrollContainer/VBoxContainer/PainelQuadro/Condicao

@onready var botao_imprimir: TextureButton = $FichaPaginas/ScrollContainer/VBoxContainer/HBoxContainer/Imprimir

var paciente_atual: Paciente = null


func _ready() -> void:
	hide()
	campo_protocolo.text_submitted.connect(_on_protocolo_submetido)
	botao_imprimir.pressed.connect(_on_imprimir_pressed)
	
	for campo in [campo_temperatura, campo_pressao,campo_saturacao]:
		campo.focus_entered.connect(_on_campo_medicao_focus.bind(campo))

func abrir() -> void:
	show()

func fechar() -> void:
	hide()

func _on_protocolo_submetido(_texto: String) -> void:
	var protocolo := campo_protocolo.text.strip_edges()
	var paciente := GerenciadorPacientes.busca_por_protocolo(protocolo)
	
	if paciente == null:
		print("Procotolo invalido. Ficha não localizada")
		return
	
	paciente_atual = paciente
	_preencher_cadastro(paciente)
	_limpar_quadro()

func _preencher_cadastro(paciente: Paciente) -> void:
	label_nome.text = paciente.nome
	label_idade.text = str(paciente.idade) + " anos"
	label_tipo_sanguineo.text = paciente.tipo_sanguineo
	label_implantes.text = paciente.implantes
	label_transplantes.text = paciente.transplantes

func _limpar_quadro() -> void:
	campo_temperatura.clear()
	campo_pressao.clear()
	campo_saturacao.clear()
	campo_condicao.clear()
	for filho in lista_sintomas.get_children():
		filho.queue_free()

func _on_campo_medicao_focus(campo: LineEdit) -> void:
	if paciente_atual == null:
		return
	
	var chave := ""
	if campo == campo_temperatura: chave = "temperatura"
	elif campo == campo_pressao: chave = "pressao"
	elif campo == campo_saturacao: chave = "saturacao"
	
	if not paciente_atual.leitura_registradas.has(chave):
		campo.modulate = Color(1.0, 0.7, 0.7, 1.0)
	else:
		campo.modulate = Color.WHITE

func _on_imprimir_pressed() -> void:
	if paciente_atual == null or paciente_atual.ficha_impressa:
		return
	
	var ficha := {
		"temperatura": campo_temperatura.text.strip_edges(),
		"pressao": campo_pressao.text.strip_edges(),
		"saturacao": campo_saturacao.text.strip_edges(),
		"condicao": campo_condicao.text.strip_edges(),
	}
	
	GerenciadorPacientes.registrar_ficha(paciente_atual.protocolo, ficha)
	paciente_atual.ficha = true
