extends Node
## Autoload: GerenciadorTutorial (deixe por ÚLTIMO na lista de Autoloads).
##
## Ações do jogo que precisam respeitar o tutorial chamam, na PRIMEIRA linha:
##     if GerenciadorTutorial.filtrar(self): return
## Eventos do jogo avisam o tutorial com:
##     GerenciadorTutorial.notificar("nome_do_evento")

signal sequencia_iniciada(id: String)
signal sequencia_concluida(id: String)

enum Fase { INATIVA, ESPERA, FALA }

const BRILHO := Color(1.8, 1.8, 1.8)
const CARACTERES_POR_SEGUNDO := 45.0
const SOM_FALA := "fala"

const CENA_UI := preload("res://moldes/Instanciaveis/tutorial_ui.tscn")

 
## ids das sequências já vistas (vale para a sessão; entra no save/load quando existir).
var concluidas: Dictionary = {}
var ativo := false
 
var _sequencia: TutorialSequencia
var _indice := 0
var _fase := Fase.INATIVA
 
var _alvo: CanvasItem
var _alvo_caminho := ""
var _modulate_original := Color.WHITE
var _tween_brilho: Tween
 
var _digitando := false
var _tween_texto: Tween
var _tween_ui: Tween
 
var _camada: CanvasLayer
var _bloqueio: ColorRect
var _retrato: TextureRect
var _painel: PanelContainer
var _label_nome: Label
var _texto: RichTextLabel
var _dica: Label
var _botao_pular: Button




const LARGURA_BALAO := 560.0
const MARGEM_TOPO := 20.0
const BRILHO_DESTAQUE := Color(1.7, 1.7, 1.7)
var _alvo_atual: CanvasItem
var _tween_destaque: Tween
var _label_narrador: Label
var _label_texto: RichTextLabel
var _botao_continuar: Button


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	## Eventos que já existem como sinais: nenhuma outra edição necessária.
	GerenciadorAla.ficha_finalizada.connect(func(): notificar("ficha_finalizada"))
	GerenciadorAla.novo_paciente_chamado.connect(func(): notificar("paciente_chamado"))
	GerenciadorAla.remedio_entregue.connect(func(_correto): notificar("remedio_entregue"))


## --- API pública ---
func iniciar(seq: TutorialSequencia, forcar: bool = false) -> void:
	if seq == null or seq.passos.is_empty() or ativo:
		return
	if not forcar and concluidas.get(seq.id, false):
		return
	
	_sequencia = seq
	_indice = 0
	ativo = true
	if seq.pausar_tempo:
		GerenciadorTempo.pausar_tempo()
	
	if not is_instance_valid(_camada):
		_construir_ui()
	_camada.show()
	_botao_pular.show()
	
	sequencia_iniciada.emit(seq.id)
	_comecar_passo()


## O jogo avisa que algo aconteceu. Sem efeito se não houver espera por esse evento.
func notificar(evento: String) -> void:
	
	if not ativo or _fase != Fase.ESPERA or _sequencia == null:
		return
	if _passo().evento_conclusao == evento:
		_concluir_espera()


## Chamado pelas ações do jogo. Devolve true se a ação deve ser ENGOLIDA (return).
##  - Durante a fala da personagem: tudo é engolido.
##  - Passo com alvo: só o alvo funciona; se for "capturar_clique", o clique avança o
##    tutorial e a ação não acontece de verdade.
##  - Passo sem alvo: nada é bloqueado.
func filtrar(no: Node) -> bool:
	if not ativo or _sequencia == null:
		return false
	if _fase == Fase.FALA:
		return true
	if not is_instance_valid(_alvo):
		return false
	var eh_alvo := no == _alvo or _alvo.is_ancestor_of(no)
	if eh_alvo and _passo().capturar_clique:
		_concluir_espera()
		return true
	return not eh_alvo

## --- Fluxo dos passos ---
func _passo() -> TutorialPasso:
	return _sequencia.passos[_indice]

func _tem_espera(passo: TutorialPasso) -> bool:
	return passo.capturar_clique or passo.evento_conclusao != ""

func _comecar_passo() -> void:
	_limpar_brilho()
	var passo := _passo()
	if passo.narrar_primeiro and passo.texto != "":
		_narrar(passo)
	elif _tem_espera(passo):
		_esperar(passo)
	elif passo.texto != "":
		_narrar(passo)
	else:
		_proximo()

func _esperar(passo: TutorialPasso) -> void:
	_fase = Fase.ESPERA
	if passo.capturar_clique and passo.alvo == "":
		push_warning("Tutorial: passo com capturar_clique precisa de um alvo.")
	_brilhar(passo.alvo)

func _concluir_espera() -> void:
	_limpar_brilho()
	var passo := _passo()
	if not passo.narrar_primeiro and passo.texto != "":
		_narrar(passo)
	else:
		_proximo()

func _narrar(passo: TutorialPasso) -> void:
	_fase = Fase.FALA
	## Brilho durante a fala, exceto na fala que vem DEPOIS do clique no alvo.
	if passo.alvo != "" and (passo.narrar_primeiro or not _tem_espera(passo)):
		_brilhar(passo.alvo)
	
	var nome := passo.narrador if passo.narrador != "" else _sequencia.narrador_padrao
	var retrato := passo.retrato if passo.retrato else _sequencia.retrato_padrao
	_label_nome.text = nome
	_label_nome.visible = nome != ""
	_retrato.texture = retrato
	_retrato.visible = retrato != null
	_texto.text = passo.texto
	_dica.hide()
	_mostrar_ui()
	GerenciadorAudio.tocar(SOM_FALA)
	
	## Digitação
	if _tween_texto:
		_tween_texto.kill()
	_texto.visible_ratio = 0.0
	var total := _texto.get_total_character_count()
	_digitando = true
	_tween_texto = create_tween()
	_tween_texto.tween_property(_texto, "visible_ratio", 1.0, maxf(0.3, total / CARACTERES_POR_SEGUNDO))
	_tween_texto.tween_callback(_digitacao_terminou)

func _digitacao_terminou() -> void:
	_digitando = false
	_dica.show()

func _avancar_fala() -> void:
	if _fase != Fase.FALA:
		return
	if _digitando:
		if _tween_texto:
			_tween_texto.kill()
		_texto.visible_ratio = 1.0
		_digitacao_terminou()
		return
	
	_esconder_ui()
	var passo := _passo()
	if passo.narrar_primeiro and _tem_espera(passo):
		_esperar(passo)  ## a fala veio primeiro; agora o jogador age
	else:
		_proximo()

func _proximo() -> void:
	if not ativo or _sequencia == null:
		return
	_indice += 1
	GerenciadorTempo.continuar_tempo()
	print("indice: ", _indice)
	print("tamanho sequencia: ", _sequencia.passos.size())
	if _indice >= _sequencia.passos.size() - 1:
		_finalizar()
	else:
		_comecar_passo()
 
 
func _destruir_ui() -> void:
	if is_instance_valid(_camada):
		_camada.queue_free()
	_camada = null
	_bloqueio = null
	_retrato = null
	_painel = null
	_label_nome = null
	_texto = null
	_dica = null
	_botao_pular = null

func _finalizar() -> void:
	if not ativo or _sequencia == null:
		return
	_limpar_brilho()
	if _tween_texto:
		_tween_texto.kill()
	_esconder_ui()
	_botao_pular.hide()
	
	var id := _sequencia.id
	concluidas[id] = true
	if _sequencia.pausar_tempo:
		GerenciadorTempo.continuar_tempo()
	
	ativo = false
	_fase = Fase.INATIVA
	_sequencia = null
	## Esconde a camada depois do fade (se outra sequência não começou nesse meio tempo).
	get_tree().create_timer(0.3, true).timeout.connect(func():
		if not ativo:
			_destruir_ui())
	sequencia_concluida.emit(id)

## --- Brilho no alvo ---
func _brilhar(caminho: String) -> void:
	if caminho == "":
		return
	if is_instance_valid(_alvo) and _alvo_caminho == caminho:
		return
	_limpar_brilho()
	
	var cena := get_tree().current_scene
	var no: Node = cena.get_node_or_null(caminho) if cena else null
	if not (no is CanvasItem):
		push_warning("Tutorial: alvo não encontrado ou inválido: " + caminho)
		return
	
	_alvo = no
	_alvo_caminho = caminho
	_modulate_original = _alvo.modulate
	## Tween preso ao alvo: se o nó for removido, o tween morre junto.
	_tween_brilho = _alvo.create_tween().set_loops()
	_tween_brilho.tween_property(_alvo, "modulate", _modulate_original * BRILHO, 0.5)
	_tween_brilho.tween_property(_alvo, "modulate", _modulate_original, 0.5)
 
 
func _limpar_brilho() -> void:
	if _tween_brilho:
		_tween_brilho.kill()
		_tween_brilho = null
	if is_instance_valid(_alvo):
		_alvo.modulate = _modulate_original
	_alvo = null
	_alvo_caminho = ""

## --- Interface ---
func _mostrar_ui() -> void:
	_bloqueio.mouse_filter = Control.MOUSE_FILTER_STOP
	_trocar_tween_ui().set_parallel(true)
	_tween_ui.tween_property(_bloqueio, "modulate:a", 1.0, 0.2)
	_tween_ui.tween_property(_painel, "modulate:a", 1.0, 0.2)
	_tween_ui.tween_property(_retrato, "modulate:a", 1.0, 0.25)
 
 
func _esconder_ui() -> void:
	_bloqueio.mouse_filter = Control.MOUSE_FILTER_IGNORE  ## o clique volta ao jogo na hora
	_trocar_tween_ui().set_parallel(true)
	_tween_ui.tween_property(_bloqueio, "modulate:a", 0.0, 0.2)
	_tween_ui.tween_property(_painel, "modulate:a", 0.0, 0.2)
	_tween_ui.tween_property(_retrato, "modulate:a", 0.0, 0.2)
 
 
func _trocar_tween_ui() -> Tween:
	if _tween_ui:
		_tween_ui.kill()
	_tween_ui = create_tween()
	return _tween_ui
 
 
func _on_bloqueio_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_avancar_fala()


## Enter/Espaço também avançam a fala (e não vazam para os atalhos do jogo).
func _input(event: InputEvent) -> void:
	if ativo and _fase == Fase.FALA and event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_avancar_fala()
 
 
## Montada por código; estilize depois com um Theme.
func _construir_ui() -> void:
	_camada = CENA_UI.instantiate()
	add_child(_camada)
	
	_bloqueio = _camada.get_node("%Bloqueio")
	_retrato = _camada.get_node("%Retrato")
	_painel = _camada.get_node("%Painel")
	_label_nome = _camada.get_node("%Nome")
	_texto = _camada.get_node("%Texto")
	_dica = _camada.get_node("%Dica")
	_botao_pular = _camada.get_node("%BotaoPular")
	
	## Estado inicial: tudo invisível; o script anima a entrada e a saída.
	_bloqueio.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_bloqueio.modulate.a = 0.0
	_painel.modulate.a = 0.0
	_retrato.modulate.a = 0.0
	_botao_pular.hide()
	
	_bloqueio.gui_input.connect(_on_bloqueio_input)
	_botao_pular.pressed.connect(_finalizar)









## --- Fluxo dos passos ---
func _mostrar_passo() -> void:
	_limpar_destaque()
	var passo := _sequencia.passos[_indice]
	
	_label_narrador.text = passo.narrador
	_label_narrador.visible = passo.narrador != ""
	_label_texto.text = passo.texto
	_botao_continuar.visible = passo.evento_conclusao == ""
	
	_destacar(passo.alvo)

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
