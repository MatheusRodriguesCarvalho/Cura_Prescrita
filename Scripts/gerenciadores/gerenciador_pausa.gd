extends CanvasLayer
## Autoload: GerenciadorPausa
## Esc ou botão "II" pausam o jogo. Só funciona em cenas que chamarem habilitar(true).
 
const CENA_MENU := "res://Scenes/menu_inicial.tscn"  ## ajuste se o caminho for outro
 
var habilitado := false
 
var _overlay: ColorRect
var _botao_pausar: Button
var _sliders: Dictionary = {}  ## nome do bus -> HSlider


func _ready() -> void:
	layer = 110  ## acima do HUD (1) e do tutorial (100)
	process_mode = Node.PROCESS_MODE_ALWAYS  ## continua recebendo input com a árvore pausada
	_construir_ui()
	habilitar(false)

func habilitar(valor: bool) -> void:
	habilitado = valor
	_botao_pausar.visible = valor
	if not valor and get_tree().paused:
		_retomar()

func _unhandled_input(event: InputEvent) -> void:
	if habilitado and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		alternar()

func alternar() -> void:
	if get_tree().paused:
		_retomar()
	else:
		_pausar()

func _pausar() -> void:
	if not habilitado:
		return
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		return
	get_tree().paused = true
	
	TooltipInfo.esconder.emit()
	_sincronizar_sliders()
	_overlay.show()

func _retomar() -> void:
	get_tree().paused = false
	_overlay.hide()

func _ir_para_menu() -> void:
	_retomar()
	habilitar(false)
	GerenciadorTempo.encerrar_fase()
	get_tree().change_scene_to_file(CENA_MENU)

func _sincronizar_sliders() -> void:
	for bus in _sliders:
		var slider: HSlider = _sliders[bus]
		## set_value_no_signal não dispara value_changed (sem reaplicar volume nem tocar som)
		slider.set_value_no_signal(GerenciadorAudio.volume_atual(bus))

## --- Interface (montada por código; vale migrar para cena quando for estilizar) ---
func _construir_ui() -> void:
	_botao_pausar = Button.new()
	_botao_pausar.text = "II"
	_botao_pausar.focus_mode = Control.FOCUS_NONE
	_botao_pausar.set_anchors_and_offsets_preset(Control.PRESET_TOP_RIGHT, Control.PRESET_MODE_MINSIZE, 10)
	_botao_pausar.pressed.connect(_pausar)
	add_child(_botao_pausar)
	
	## O overlay em tela cheia com mouse_filter = Stop é o que bloqueia o jogo atrás.
	_overlay = ColorRect.new()
	_overlay.color = Color(0, 0, 0, 0.6)
	_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.mouse_filter = Control.MOUSE_FILTER_STOP
	_overlay.hide()
	add_child(_overlay)
	
	var centro := CenterContainer.new()
	centro.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(centro)
	
	var painel := PanelContainer.new()
	centro.add_child(painel)
	
	var caixa := VBoxContainer.new()
	caixa.custom_minimum_size = Vector2(320, 0)
	painel.add_child(caixa)
	
	var titulo := Label.new()
	titulo.text = "Pausado"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caixa.add_child(titulo)
	
	_linha_volume(caixa, "Geral", "Master")
	_linha_volume(caixa, "Música", "Musica")
	_linha_volume(caixa, "Efeitos", "Efeitos")
	
	var continuar := Button.new()
	continuar.text = "Continuar"
	continuar.pressed.connect(_retomar)
	caixa.add_child(continuar)
	
	var menu := Button.new()
	menu.text = "Menu inicial"
	menu.pressed.connect(_ir_para_menu)
	caixa.add_child(menu)
 
 
func _linha_volume(pai: Control, rotulo: String, bus: String) -> void:
	var linha := HBoxContainer.new()
	pai.add_child(linha)
	
	var nome := Label.new()
	nome.text = rotulo
	nome.custom_minimum_size = Vector2(80, 0)
	linha.add_child(nome)
	
	var slider := HSlider.new()
	slider.min_value = 0.0
	slider.max_value = 1.0
	slider.step = 0.01
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slider.custom_minimum_size = Vector2(180, 0)
	slider.value_changed.connect(func(v: float): GerenciadorAudio.definir_volume(bus, v))
	## Som de teste ao soltar o slider, para o jogador ouvir o nível.
	slider.drag_ended.connect(func(_alterado: bool): GerenciadorAudio.tocar("clique"))
	linha.add_child(slider)
	
	_sliders[bus] = slider
