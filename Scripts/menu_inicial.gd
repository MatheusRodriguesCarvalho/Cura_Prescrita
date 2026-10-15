extends Control

const CENA_JOGO := "res://Scenes/consultorio.tscn"

@onready var BotaoIniciar: TextureButton = $Menu/Botoes/BotaoIniciar
@onready var BotaoContinuar: TextureButton = $Menu/Botoes/BotaoContinuar
@onready var BotaoOpcoes: TextureButton = $Menu/Botoes/BotaoOpcoes
@onready var BotaoGuia: TextureButton = $Menu/Botoes/BotaoGuia
@onready var BotaoCreditos: TextureButton = $Menu/Botoes/BotaoCreditos
@onready var BotaoSair: TextureButton = $Menu/Botoes/BotaoSair

@onready var painel_opcoes: Control = $Paineis/Opcoes
@onready var painel_guia: Control = $Paineis/GuiaResumo
@onready var painel_creditos: Control = $Paineis/Creditos
@onready var fundo: ColorRect = $Paineis/Fundo


func _ready() -> void:
	GerenciadorAudio.tocar_musica_cena("menu")

	## Continuar só existe se um jogo já foi iniciado nesta sessão.
	BotaoContinuar.visible = GerenciadorPacientes.jogo_iniciado

	BotaoIniciar.pressed.connect(_on_iniciar_pressed)
	BotaoContinuar.pressed.connect(_on_continuar_pressed)
	BotaoOpcoes.pressed.connect(_on_opcoes_pressed)
	BotaoGuia.pressed.connect(_on_guia_pressed)
	BotaoCreditos.pressed.connect(_on_creditos_pressed)
	BotaoSair.pressed.connect(_on_sair_pressed)

	painel_opcoes.hide()
	painel_guia.hide()
	painel_creditos.hide()
	fundo.hide()

	painel_guia.get_node("BotaoFechar").pressed.connect(_on_botao_fechar)
	painel_creditos.get_node("BotaoFechar").pressed.connect(_on_botao_fechar)

	## O fundo escuro acompanha qualquer painel aberto (inclusive o de opções, que
	## se esconde sozinho em menu_painel_opcoes.gd) e bloqueia os botões do menu.
	for painel in [painel_opcoes, painel_guia, painel_creditos]:
		painel.visibility_changed.connect(_atualizar_fundo)


func _atualizar_fundo() -> void:
	fundo.visible = painel_opcoes.visible or painel_guia.visible or painel_creditos.visible


func _on_botao_fechar() -> void:
	GerenciadorAudio.tocar("clique")
	painel_guia.hide()
	painel_creditos.hide()


## --- Iniciar: novo jogo completo ---
func _on_iniciar_pressed() -> void:
	GerenciadorAudio.tocar("clique")
	if GerenciadorPacientes.jogo_iniciado:
		_confirmar_novo_jogo()
	else:
		_novo_jogo()


func _confirmar_novo_jogo() -> void:
	var dialogo := ConfirmationDialog.new()
	dialogo.dialog_text = "Começar um novo jogo apaga o progresso atual. Continuar?"
	dialogo.ok_button_text = "Novo jogo"
	dialogo.cancel_button_text = "Cancelar"
	dialogo.confirmed.connect(_novo_jogo)
	dialogo.canceled.connect(dialogo.queue_free)
	add_child(dialogo)
	dialogo.popup_centered()


func _novo_jogo() -> void:
	GerenciadorPacientes.reiniciar_jogo()
	_entrar_no_jogo()


## --- Continuar: recomeça o dia em que o jogador saiu ---
func _on_continuar_pressed() -> void:
	GerenciadorAudio.tocar("clique")
	GerenciadorPacientes.iniciar_novo_dia()
	_entrar_no_jogo()


func _entrar_no_jogo() -> void:
	GerenciadorAla.remedio_atual = null  ## o remédio da sessão anterior morreu com a cena
	GerenciadorTempo.parar()
	get_tree().change_scene_to_file(CENA_JOGO)


## --- Painéis ---
func _on_opcoes_pressed() -> void:
	GerenciadorAudio.tocar("clique")
	_mostrar_painel(painel_opcoes)

func _on_guia_pressed() -> void:
	GerenciadorAudio.tocar("clique")
	_mostrar_painel(painel_guia)

func _on_creditos_pressed() -> void:
	GerenciadorAudio.tocar("clique")
	_mostrar_painel(painel_creditos)

func _on_sair_pressed() -> void:
	get_tree().quit()

func _mostrar_painel(painel: Control) -> void:
	painel_opcoes.hide()
	painel_guia.hide()
	painel_creditos.hide()
	painel.show()
