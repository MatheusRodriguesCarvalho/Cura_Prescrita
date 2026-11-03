extends Control

const CENA_JOGO := "res://Scenes/consultorio.tscn"
const CENA_ABERTURA := "res://Scenes/visual_novel.tscn"

@export var BotaoIniciar: TextureButton
@export var BotaoContinuar: TextureButton
@export var BotaoOpcoes: TextureButton
@export var BotaoGuia: TextureButton
@export var BotaoCreditos: TextureButton
@export var BotaoSair: TextureButton

@export_category("Painel")
@export var _paineis: Control
@export var painel_dificuldade: Control
@export var painel_opcoes: Control
@export var painel_guia: Control
@export var painel_creditos: Control
@export var fundo: ColorRect

 
var _botao_confirmar: Button
var _aviso_novo_jogo: Label


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
	
	_montar_painel_dificuldade()
	
	painel_dificuldade.hide()
	painel_opcoes.hide()
	painel_guia.hide()
	painel_creditos.hide()
	fundo.hide()
	
	painel_dificuldade.get_node("VBoxContainer/HBoxContainer/BotaoCancelar").pressed.connect(_on_botao_fechar)
	painel_opcoes.get_node("VBoxContainer/BotaoFechar").pressed.connect(_on_botao_fechar)
	painel_guia.get_node("BotaoFechar").pressed.connect(_on_botao_fechar)
	painel_creditos.get_node("BotaoFechar").pressed.connect(_on_botao_fechar)
	
	## O fundo escuro acompanha qualquer painel aberto (inclusive o de opções, que
	## se esconde sozinho em menu_painel_opcoes.gd) e bloqueia os botões do menu.
	for painel in [painel_opcoes, painel_guia, painel_creditos]:
		painel.visibility_changed.connect(_atualizar_fundo)


func _atualizar_fundo() -> void:
	fundo.visible = painel_dificuldade.visible or painel_opcoes.visible or painel_guia.visible or painel_creditos.visible


func _on_botao_fechar() -> void:
	GerenciadorAudio.tocar("clique")
	painel_dificuldade.hide()
	painel_opcoes.hide()
	painel_guia.hide()
	painel_creditos.hide()
	fundo.hide()


## --- Iniciar: novo jogo completo ---
func _on_iniciar_pressed() -> void:
	GerenciadorAudio.tocar("clique")
	var em_andamento := GerenciadorPacientes.jogo_iniciado
	_aviso_novo_jogo.visible = em_andamento
	_botao_confirmar.text = "Novo jogo" if em_andamento else "Começar"
	_paineis.preparar_dificuldade()
	_mostrar_painel(painel_dificuldade)

func _on_confirmar_dificuldade() -> void:
	GerenciadorAudio.tocar("clique")
	_paineis.aplicar_dificuldade()  ## só aqui o modo muda de fato
	painel_dificuldade.hide()
	fundo.hide()
	_novo_jogo()

func _novo_jogo() -> void:
	GerenciadorPacientes.reiniciar_jogo()  ## marca a abertura como pendente
	_entrar_no_jogo(CENA_ABERTURA)


## --- Continuar: recomeça o dia em que o jogador saiu ---
func _on_continuar_pressed() -> void:
	GerenciadorAudio.tocar("clique")
	GerenciadorPacientes.iniciar_novo_dia()
	_entrar_no_jogo()

func _entrar_no_jogo(cena: String = CENA_JOGO) -> void:
	GerenciadorAla.remedio_atual = null
	GerenciadorTempo.parar()
	get_tree().change_scene_to_file(cena)


## --- Painéis ---
func _montar_painel_dificuldade() -> void:
	var caixa: VBoxContainer = painel_dificuldade.get_node("VBoxContainer")
	
	_botao_confirmar = caixa.get_node("HBoxContainer/BotaoConfirmar")
	_botao_confirmar.pressed.connect(_on_confirmar_dificuldade)
	
	_aviso_novo_jogo = Label.new()
	_aviso_novo_jogo.text = "Atenção: começar um novo jogo apaga o progresso atual."
	_aviso_novo_jogo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_aviso_novo_jogo.custom_minimum_size = Vector2(141, 0)
	_aviso_novo_jogo.add_theme_color_override("font_color", Color(1.0, 0.6, 0.5))
	_aviso_novo_jogo.hide()
	caixa.add_child(_aviso_novo_jogo)
	caixa.move_child(_aviso_novo_jogo, caixa.get_node("Descricao").get_index() + 1)

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
	painel_dificuldade.hide()
	painel_opcoes.hide()
	painel_guia.hide()
	painel_creditos.hide()
	fundo.show()
	painel.show()
