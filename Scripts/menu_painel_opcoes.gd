extends Control

@onready var opcao_dificuldade: OptionButton = $VBoxContainer/Dificuldade
@onready var slider_geral: HSlider = $VBoxContainer/VolumeGeral
@onready var slider_musica: HSlider = $VBoxContainer/VolumeMusica
@onready var slider_efeitos: HSlider = $VBoxContainer/VolumeEfeitos
@onready var botao_fechar: Button = $VBoxContainer/BotaoFechar

func _ready() -> void:
	opcao_dificuldade.add_item("Cronômetro")
	opcao_dificuldade.add_item("Estamina")
	opcao_dificuldade.selected = GerenciadorTempo.modo
	opcao_dificuldade.item_selected.connect(_on_dificuldade_selected)
	
	for slider in [slider_geral, slider_musica, slider_efeitos]:
		slider.min_value = 0.0
		slider.max_value = 1.0
	
	slider_geral.value = _volume_atual("Master")
	slider_musica.value = _volume_atual("Musica")
	slider_efeitos.value = _volume_atual("Efeitos")
	
	slider_geral.value_changed.connect(func(v): _definir_volume("Master", v))
	slider_musica.value_changed.connect(func(v): _definir_volume("Musica", v))
	slider_efeitos.value_changed.connect(func(v): _definir_volume("Efeitos", v))
	
	botao_fechar.pressed.connect(hide)

func _on_dificuldade_selected(indice: int) -> void:
	GerenciadorTempo.modo = indice as GerenciadorTempo.Modo


func _definir_volume(bus_nome: String, valor_linear: float) -> void:
	var indice_bus := AudioServer.get_bus_index(bus_nome)
	if indice_bus == -1:
		return  # barramento ainda não existe no Audio Bus Layout
	AudioServer.set_bus_volume_db(indice_bus, linear_to_db(max(valor_linear, 0.0001)))

func _volume_atual(bus_nome: String) -> float:
	var indice_bus := AudioServer.get_bus_index(bus_nome)
	if indice_bus == -1:
		return 1.0
	return db_to_linear(AudioServer.get_bus_volume_db(indice_bus))
