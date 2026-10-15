extends Node
## Autoload: GerenciadorTutorial (deixe por ÚLTIMO na lista de Autoloads).

signal sequencia_iniciada(id: String)
signal sequencia_concluida(id: String)

const LARGURA_BALAO := 560.0
const MARGEM_TOPO := 20.0
const BRILHO_DESTAQUE := Color(1.7, 1.7, 1.7)

## ids das sequências já vistas. Entra no save/load quando ele existir.
var concluidas: Dictionary = {}
var ativo := false

var _sequencia: TutorialSequencia
var _indice := 0
var _alvo_atual: CanvasItem
var _modulate_original := Color.WHITE
var _tween_destaque: Tween

var _camada: CanvasLayer
var _painel: PanelContainer
var _label_narrador: Label
var _label_texto: RichTextLabel
var _botao_continuar: Button
var _botao_pular: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_construir_ui()
	_camada.hide()
	
	## Eventos que já existem como sinais: nenhuma outra edição necessária.
	GerenciadorAla.ficha_finalizada.connect(func(): notificar("ficha_finalizada"))
	GerenciadorAla.novo_paciente_chamado.connect(func(): notificar("paciente_chamado"))


## --- API pública ---
## Inicia uma sequência. Se já foi concluída, ignora (a menos que forcar = true).
func iniciar(seq: TutorialSequencia, forcar: bool = false) -> void:
	if seq == null or seq.passos.is_empty() or ativo:
		return
	if not forcar and concluidas.get(seq.id, false):
		return
	
	_sequencia = seq
	_indice = 0
	ativo = true
	if seq.pausar_tempo:
		GerenciadorTempo.pausado = true
	
	_camada.show()
	sequencia_iniciada.emit(seq.id)
	_mostrar_passo()


## Chamado pelo resto do jogo quando algo acontece. Sem efeito se não houver tutorial ativo.
func notificar(evento: String) -> void:
	if not ativo:
		return
	if _sequencia.passos[_indice].evento_conclusao == evento:
		_proximo()


## --- Fluxo dos passos ---
func _mostrar_passo() -> void:
	_limpar_destaque()
	var passo := _sequencia.passos[_indice]
	
	_label_narrador.text = passo.narrador
	_label_narrador.visible = passo.narrador != ""
	_label_texto.text = passo.texto
	_botao_continuar.visible = passo.evento_conclusao == ""
	
	_destacar(passo.alvo)


func _proximo() -> void:
	_indice += 1
	if _indice >= _sequencia.passos.size():
		_finalizar()
	else:
		_mostrar_passo()


func _finalizar() -> void:
	_limpar_destaque()
	_camada.hide()
	
	var id := _sequencia.id
	concluidas[id] = true
	if _sequencia.pausar_tempo:
		GerenciadorTempo.pausado = false
	
	ativo = false
	_sequencia = null
	sequencia_concluida.emit(id)


## --- Destaque (pulso de brilho no nó alvo) ---
func _destacar(caminho: String) -> void:
	if caminho == "":
		return
	var cena := get_tree().current_scene
	var no: Node = cena.get_node_or_null(caminho) if cena else null
	if not (no is CanvasItem):
		push_warning("Tutorial: alvo não encontrado ou inválido: " + caminho)
		return
	
	_alvo_atual = no
	_modulate_original = _alvo_atual.modulate
	## Tween preso ao alvo: se o nó for removido, o tween morre junto.
	_tween_destaque = _alvo_atual.create_tween().set_loops()
	_tween_destaque.tween_property(_alvo_atual, "modulate", _modulate_original * BRILHO_DESTAQUE, 0.5)
	_tween_destaque.tween_property(_alvo_atual, "modulate", _modulate_original, 0.5)


func _limpar_destaque() -> void:
	if _tween_destaque:
		_tween_destaque.kill()
		_tween_destaque = null
	if is_instance_valid(_alvo_atual):
		_alvo_atual.modulate = _modulate_original
	_alvo_atual = null


## --- Interface (montada por código; estilize depois com um Theme) ---
func _construir_ui() -> void:
	_camada = CanvasLayer.new()
	_camada.layer = 100
	add_child(_camada)
	
	_painel = PanelContainer.new()
	_painel.custom_minimum_size = Vector2(LARGURA_BALAO, 0)
	_painel.set_anchors_and_offsets_preset(Control.PRESET_CENTER_TOP, Control.PRESET_MODE_MINSIZE, int(MARGEM_TOPO))
	_painel.grow_horizontal = Control.GROW_DIRECTION_BOTH
	_camada.add_child(_painel)
	
	var caixa := VBoxContainer.new()
	_painel.add_child(caixa)
	
	_label_narrador = Label.new()
	caixa.add_child(_label_narrador)
	
	_label_texto = RichTextLabel.new()
	_label_texto.bbcode_enabled = true
	_label_texto.fit_content = true
	_label_texto.custom_minimum_size = Vector2(LARGURA_BALAO - 20.0, 0)
	caixa.add_child(_label_texto)
	
	var botoes := HBoxContainer.new()
	botoes.alignment = BoxContainer.ALIGNMENT_END
	caixa.add_child(botoes)
	
	_botao_pular = Button.new()
	_botao_pular.text = "Pular tutorial"
	_botao_pular.pressed.connect(_finalizar)
	botoes.add_child(_botao_pular)
	
	_botao_continuar = Button.new()
	_botao_continuar.text = "Continuar"
	_botao_continuar.pressed.connect(_proximo)
	botoes.add_child(_botao_continuar)
