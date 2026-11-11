extends Control

@export var campo_protocolo: LineEdit

@export var painel_cadastro: VBoxContainer

@onready var campo_temperatura: LineEdit = %Temperatura
@onready var campo_saturacao: LineEdit = %Saturacao
@onready var campo_pressao: LineEdit = %Pressao
@onready var campo_condicao: LineEdit = %Condicao

@onready var botao_imprimir: TextureButton = $FichaPaginas/VBoxContainer/HBoxContainer/Imprimir
@onready var botao_retornar: TextureButton = $FichaPaginas/VBoxContainer/HBoxContainer/Retornar
@onready var botao_excluir: TextureButton = $FichaPaginas/VBoxContainer/HBoxContainer/Excluir


var paciente_atual: Paciente = null


func _ready() -> void:
	hide()
	botao_excluir.hide()
	
	campo_protocolo.text_submitted.connect(_on_protocolo_submetido)
	campo_protocolo.focus_exited.connect(_on_protocolo_submetido_por_troca)
	
	botao_imprimir.pressed.connect(_on_imprimir_pressed)
	botao_excluir.pressed.connect(_on_excluir_pressed)
	botao_retornar.pressed.connect(_on_retornar_pressed)
	
	GerenciadorAla.novo_paciente_chamado.connect(_limpar_quadro)
	

func abrir() -> void:
	show()

func fechar() -> void:
	hide()

func _on_protocolo_submetido(_texto: String) -> void:
	var protocolo := campo_protocolo.text.strip_edges()
	var paciente: Paciente = GerenciadorPacientes.busca_por_protocolo(protocolo)
	
	if paciente == null:
		TooltipInfo.aviso.emit("Protocolo Invalido...")
		return
	
	paciente_atual = paciente
	_preencher_cadastro(paciente)

func _on_protocolo_submetido_por_troca() -> void:
	var protocolo := campo_protocolo.text.strip_edges()
	var paciente: Paciente = GerenciadorPacientes.busca_por_protocolo(protocolo)
	
	if paciente == null:
		TooltipInfo.aviso.emit("Protocolo Invalido...")
		return
	
	paciente_atual = paciente
	_preencher_cadastro(paciente)

func _preencher_cadastro(paciente: Paciente) -> void:
	GerenciadorTutorial.notificar("protocolo_digitado")
	
	_set_dado("Nome", paciente.nome)
	_set_dado("Idade", "%d anos" % paciente.idade)
	_set_dado("TipoSangue", paciente.tipo_sanguineo)
	_set_dado("Implantes", paciente.implantes)
	_set_dado("Transplantes", paciente.transplantes)

func _set_dado(linha: String, valor: String) -> void:
	var campo := painel_cadastro.get_node(linha).get_node("LineEdit") as LineEdit
	campo.text = valor

func _limpar_quadro() -> void:
	campo_temperatura.clear()
	campo_pressao.clear()
	campo_saturacao.clear()
	campo_condicao.clear()

func limpar_informacoes() -> void:
	_limpar_quadro()
	
	campo_protocolo.text = ""
	for linha in painel_cadastro.get_children():
		(linha.get_node("LineEdit") as LineEdit).text = ""
	
	if paciente_atual:
		paciente_atual.ficha_impressa = false
	
	botao_imprimir.show()
	botao_excluir.hide()


## --- Ações dos Botões ---
func _on_retornar_pressed() -> void:
	GerenciadorAudio.tocar("clique")
	hide()

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
	paciente_atual.ficha_impressa = true
	
	GerenciadorAudio.tocar("imprimir")
	GerenciadorTutorial.notificar("ficha_impressa")
	
	## Signals
	GerenciadorAla.ficha_finalizada.emit()
	
	
	hide()
	botao_excluir.show()
	botao_imprimir.hide()

func _on_excluir_pressed() -> void:
	if paciente_atual:
		paciente_atual.ficha_impressa = false
	GerenciadorAla.editar_ficha.emit()
	
	GerenciadorAudio.tocar("lixo")
	
	botao_imprimir.show()
	botao_excluir.hide()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		fechar()
