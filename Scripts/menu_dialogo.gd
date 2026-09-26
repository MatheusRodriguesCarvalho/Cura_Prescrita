extends Control

var paciente_atual: Paciente = null

@onready var botao_protocolo: Button = $VBoxContainer/BotaoProtocolo
@onready var botao_sintoma: Button = $VBoxContainer/BotaoSintoma
@onready var botao_vida: Button = $VBoxContainer/BotaoVida

var texto_botao_protocolo: Array[String] = [
	"Pedir por Protocolo",
	"Mais Informações",
	"Solicitar Código",
]
var texto_botao_sintoma: Array[String] = [
	"Como se sente?",
	"Tudo bem?",
	"Como está?",
	"Em que posso ajudar?",
]
var texto_botao_vida: Array[String] = [
	"Semana difícil...",
	"Como vai sua vida?",
	"O que tem feito de bom?",
]

func _ready() -> void:
	hide()
	botao_protocolo.pressed.connect(_on_opcao_protocolo)
	botao_sintoma.pressed.connect(_on_opcao_sintoma)
	botao_vida.pressed.connect(_on_opcao_vida)
	
	## TODO, passivel de realocação ou criar uma função pra isso
	botao_protocolo.text = texto_botao_protocolo[randi() % texto_botao_protocolo.size()]
	botao_sintoma.text = texto_botao_sintoma[randi() % texto_botao_sintoma.size()]
	botao_vida.text = texto_botao_vida[randi() % texto_botao_vida.size()]


func abrir(paciente: Paciente) -> void:
	if visible and paciente_atual == paciente:
		_fechar()
		return
	paciente_atual = paciente
	global_position = paciente.global_position + Vector2(40, -60)
	show()

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if not get_global_rect().has_point(get_global_mouse_position()):
			_fechar()

func sair(paciente: Paciente) -> void:
	_fechar()

func _fechar() -> void:
	hide()
	paciente_atual = null

func _on_opcao_protocolo() -> void:
	GerenciadorDialogos.pedir_protocolo(paciente_atual)
	_fechar()

func _on_opcao_sintoma() -> void:
	GerenciadorDialogos.falar.emit(paciente_atual.nome, paciente_atual.doenca.fala_sintoma_aleatoria())
	_fechar()

func _on_opcao_vida() -> void:
	var par: Dictionary = paciente_atual.fala_vida_aleatoria()
	if not par.is_empty():
		GerenciadorDialogos.falar.emit("Alê", par["pergunta"])
		await get_tree().create_timer(GerenciadorDialogos.tempo_exibicao_2).timeout
		GerenciadorDialogos.falar.emit(paciente_atual.nome, par["resposta"])
	_fechar()
