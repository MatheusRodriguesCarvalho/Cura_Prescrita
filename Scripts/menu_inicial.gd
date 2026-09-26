extends Control

@onready var painel_opcoes: Control = $Paineis/Opcoes
@onready var painel_guia: Control = $Paineis/GuiaResumo
@onready var painel_creditos: Control = $Paineis/Creditos

@onready var musica_fundo: AudioStreamPlayer = $Audio


func _ready() -> void:
	musica_fundo.play()
	
	$VBoxContainer/BotaoIniciar.pressed.connect(_on_iniciar_pressed)
	$VBoxContainer/BotaoOpcoes.pressed.connect(_on_opcoes_pressed)
	$VBoxContainer/BotaoGuia.pressed.connect(_on_guia_pressed)
	$VBoxContainer/BotaoCreditos.pressed.connect(_on_creditos_pressed)
	$VBoxContainer/BotaoSair.pressed.connect(_on_sair_pressed)
	
	painel_opcoes.hide()
	painel_guia.hide()
	painel_creditos.hide()
	
	painel_guia.get_node("BotaoFechar").pressed.connect(painel_guia.hide)
	painel_creditos.get_node("BotaoFechar").pressed.connect(painel_creditos.hide)

func _on_iniciar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/consultorio.tscn")

func _on_opcoes_pressed() -> void:
	GerenciadorAudio.tocar("clique")
	print("Opções Aberto")
	##_mostrar_painel(painel_opcoes)

func _on_guia_pressed() -> void:
	print("Guia Aberto")
	_mostrar_painel(painel_guia)

func _on_creditos_pressed() -> void:
	print("Créditos Aberto")
	_mostrar_painel(painel_creditos)

func _on_sair_pressed() -> void:
	get_tree().quit()

func _mostrar_painel(painel: Control) -> void:
	painel_opcoes.hide()
	painel_guia.hide()
	painel_creditos.hide()
	painel.show()
