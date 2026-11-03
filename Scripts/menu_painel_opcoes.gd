extends Control

@export var opcao_dificuldade: OptionButton
@export var descricao_dificuldade: Label

@export var slider_geral: HSlider
@export var slider_musica: HSlider
@export var slider_efeitos: HSlider
@export var botao_fechar: Button

@export var opcao_resolucao: OptionButton
@export var check_tela_cheia: CheckButton

var descricoes: Array[String] = [
	"O tempo do expediente corre sozinho. Quem pensa e não age, perde tempo.",
	"O tempo só passa quando você age. Dá para ler e pensar com calma, mas cada ação gasta estamina.",
]


func _ready() -> void:
	opcao_dificuldade.add_item("Cronômetro")
	opcao_dificuldade.add_item("Estamina")
	opcao_dificuldade.item_selected.connect(_atualizar_descricao)  ## escolher NÃO muda o modo ainda
	preparar_dificuldade()
	
	for slider in [slider_geral, slider_musica, slider_efeitos]:
		slider.min_value = 0.0
		slider.max_value = 1.0
		slider.step = 0.01
	
	slider_geral.value = _volume_atual("Master")
	slider_musica.value = _volume_atual("Musica")
	slider_efeitos.value = _volume_atual("Efeitos")
	
	slider_geral.value_changed.connect(func(v): _definir_volume("Master", v))
	slider_musica.value_changed.connect(func(v): _definir_volume("Musica", v))
	slider_efeitos.value_changed.connect(func(v): _definir_volume("Efeitos", v))
	
	
	for nome in GerenciadorVideo.NOMES:
		opcao_resolucao.add_item(nome)
	opcao_resolucao.select(GerenciadorVideo.indice_atual)
	check_tela_cheia.set_pressed_no_signal(GerenciadorVideo.tela_cheia)
	opcao_resolucao.disabled = GerenciadorVideo.tela_cheia
	
	opcao_resolucao.item_selected.connect(func(i: int):
		GerenciadorVideo.aplicar_resolucao(i)
		GerenciadorVideo.salvar())
	
	check_tela_cheia.toggled.connect(func(ligado: bool):
		GerenciadorVideo.definir_tela_cheia(ligado)
		opcao_resolucao.disabled = ligado  ## a janela só tem tamanho próprio fora da tela cheia
		GerenciadorVideo.salvar())

## --- Dificuldade ---
## Chamado pelo menu ao abrir o painel: mostra o modo atual e a descrição dele.
func preparar_dificuldade() -> void:
	opcao_dificuldade.select(GerenciadorTempo.modo)
	_atualizar_descricao(opcao_dificuldade.selected)

## Chamado ao confirmar: só aqui o modo muda de fato (cancelar não altera nada).
func aplicar_dificuldade() -> void:
	GerenciadorTempo.modo = opcao_dificuldade.selected as GerenciadorTempo.Modo

func _atualizar_descricao(indice: int) -> void:
	descricao_dificuldade.text = descricoes[indice]


## --- Volume ---
func _definir_volume(bus_nome: String, valor_linear: float) -> void:
	var indice_bus := AudioServer.get_bus_index(bus_nome)
	if indice_bus == -1:
		return
	AudioServer.set_bus_mute(indice_bus, valor_linear <= 0.0)
	if valor_linear > 0.0:
		AudioServer.set_bus_volume_db(indice_bus, linear_to_db(valor_linear))

func _volume_atual(bus_nome: String) -> float:
	var indice_bus := AudioServer.get_bus_index(bus_nome)
	if indice_bus == -1:
		return 1.0
	if AudioServer.is_bus_mute(indice_bus):
		return 0.0
	return db_to_linear(AudioServer.get_bus_volume_db(indice_bus))
