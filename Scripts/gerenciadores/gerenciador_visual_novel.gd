extends Node2D

@export_dir var pasta_cenas: String = "res://Arquivos/Cenas VN/"
@export_file("*.tscn") var cena_proxima_dia: String = "res://Scenes/consultorio.tscn"
@export var cena_teste: CenaVN  ## opcional: força uma cena (ignora o filtro por fase)
@export var musica_cena: String = "casa"  ## subpasta em Sons/Musicas; vazio = sem música
 

## Duração da digitação = BASE + POR_CHAR * caracteres (100 chars = 3s, 200 chars = 5s)
const DURACAO_BASE := 1.0
const DURACAO_POR_CHAR := 0.02
const CHARS_POR_SOM := 2
const SOM_DIGITACAO := "digitacao"
const COR_FALANDO := Color(1, 1, 1, 1)
const COR_CALADO := Color(0.55, 0.55, 0.6, 1)
const ESCALA_FALANDO := 1.04
 

@onready var fundo: Sprite2D = $Mundo/Local
@onready var personagens: Node2D = $Mundo/Personagens
@onready var caixa: VBoxContainer = $CanvasLayer/VisualNovel
@onready var fundo_nome: PanelContainer = $CanvasLayer/VisualNovel/FundoNome
@onready var label_nome: Label = $CanvasLayer/VisualNovel/FundoNome/Nome
@onready var label_texto: RichTextLabel = $CanvasLayer/VisualNovel/FundoFala/Fala
@onready var clique_tela: Control = $CanvasLayer/CliqueTela
@onready var card_dia: Label = $CanvasLayer/CardDia
@onready var fade: ColorRect = $CanvasLayer/Fade
 

var cena: CenaVN
var indice := 0
var digitando := false
var encerrando := false
var tween_texto: Tween
var _ultimo_visivel := 0
var _revelados: Dictionary = {}   ## nome do personagem -> true
var _escala_base: Dictionary = {} ## nome do personagem -> Vector2 definido no editor
 
func _ready() -> void:
	_preparar_ui()
	
	for p in personagens.get_children():
		if p is Sprite2D:
			_escala_base[p.name] = p.scale
			p.hide()
	
	cena = cena_teste if cena_teste else _escolher_cena_do_dia()
	if cena == null or cena.falas.is_empty():
		push_warning("Nenhuma CenaVN para a fase %d" % GerenciadorPacientes.fase_atual)
		_encerrar()
		return
	
	if cena.fundo:
		fundo.texture = cena.fundo
	if musica_cena != "":
		GerenciadorAudio.tocar_musica_cena(musica_cena, true)
	
	create_tween().tween_property(fade, "modulate:a", 0.0, 0.6)
	_mostrar_fala()


## Só o CliqueTela recebe o mouse; todo o resto deixa o clique passar.
func _preparar_ui() -> void:
	_ignorar_mouse(caixa)
	## fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	## card_dia.mouse_filter = Control.MOUSE_FILTER_IGNORE
	## clique_tela.mouse_filter = Control.MOUSE_FILTER_STOP
	clique_tela.show()
	clique_tela.gui_input.connect(_on_clique_tela)
	
	## fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	fade.show()
	fade.modulate.a = 1.0
	
	## card_dia.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	## card_dia.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	## card_dia.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	card_dia.show()
	card_dia.modulate.a = 0.0
	## O card precisa ser desenhado acima do Fade
	card_dia.get_parent().move_child(card_dia, -1)
	
	## label_texto.bbcode_enabled = true

func _ignorar_mouse(no: Node) -> void:
	if no is Control:
		(no as Control).mouse_filter = Control.MOUSE_FILTER_IGNORE
	for filho in no.get_children():
		_ignorar_mouse(filho)

func _escolher_cena_do_dia() -> CenaVN:
	var fase := GerenciadorPacientes.fase_atual
	var melhor: CenaVN = null
	var dir := DirAccess.open(pasta_cenas)
	if dir == null:
		return null
	
	dir.list_dir_begin()
	var arquivo := dir.get_next()
	while arquivo != "":
		if not dir.current_is_dir():
			var nome := arquivo.trim_suffix(".remap")
			if nome.get_extension() == "tres":
				var c := load(pasta_cenas.path_join(nome)) as CenaVN
				if c:
					if c.fase == fase:
						dir.list_dir_end()
						return c
					## Fallback: a mais recente que já deveria ter ocorrido
					if c.fase < fase and (melhor == null or c.fase > melhor.fase):
						melhor = c
		arquivo = dir.get_next()
	dir.list_dir_end()
	
	return melhor

func _on_clique_tela(event: InputEvent) -> void:
	if encerrando:
		return
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if digitando:
			_completar_texto()
		else:
			_avancar()

func _avancar() -> void:
	indice += 1
	if indice >= cena.falas.size():
		_encerrar()
		return
	_mostrar_fala()


## --- Fala atual ---
func _mostrar_fala() -> void:
	var fala := cena.falas[indice]
	var nome := fala.get_nome()
	
	fundo_nome.visible = nome != ""
	label_nome.text = nome
	label_texto.text = fala.texto
	
	_destacar(fala)
	_iniciar_digitacao()



## O nome do nó em Mundo/Personagens deve ser igual ao nome da FalaVN.
func _achar_personagem(nome: String) -> Sprite2D:
	var alvo := nome.strip_edges().to_lower()
	if alvo == "":
		return null
	for p in personagens.get_children():
		if p is Sprite2D and String(p.name).to_lower() == alvo:
			return p
	return null

func _destacar(fala: FalaVN) -> void:
	var falante := _achar_personagem(fala.get_nome())
	
	if falante:
		falante.frame = clampi(fala.expressao, 0, falante.hframes * falante.vframes - 1)
		if not _revelados.has(falante.name):
			_revelados[falante.name] = true
			falante.modulate.a = 0.0
			falante.show()
	
	for p in personagens.get_children():
		if not (p is Sprite2D) or not _revelados.has(p.name):
			continue
		var sprite := p as Sprite2D
		var ativo := sprite == falante
		var base: Vector2 = _escala_base[sprite.name]
		var t := create_tween().set_parallel(true)
		t.tween_property(sprite, "modulate", COR_FALANDO if ativo else COR_CALADO, 0.2)
		t.tween_property(sprite, "scale", base * (ESCALA_FALANDO if ativo else 1.0), 0.2)
		sprite.z_index = 1 if ativo else 0


## --- Digitação ---
func _iniciar_digitacao() -> void:
	if tween_texto:
		tween_texto.kill()
	
	var total := label_texto.get_total_character_count()
	label_texto.visible_characters = 0
	_ultimo_visivel = 0
	digitando = true
	
	if total == 0:
		_completar_texto()
		return
	
	var duracao := DURACAO_BASE + DURACAO_POR_CHAR * total
	tween_texto = create_tween()
	tween_texto.tween_property(label_texto, "visible_characters", total, duracao)
	tween_texto.tween_callback(func(): digitando = false)

func _process(_delta: float) -> void:
	if not digitando:
		return
	var atual := label_texto.visible_characters
	if atual - _ultimo_visivel >= CHARS_POR_SOM:
		var trecho := label_texto.get_parsed_text().substr(_ultimo_visivel, atual - _ultimo_visivel)
		if trecho.strip_edges() != "":
			GerenciadorAudio.tocar(SOM_DIGITACAO)
		_ultimo_visivel = atual

func _completar_texto() -> void:
	if tween_texto:
		tween_texto.kill()
	label_texto.visible_characters = -1
	digitando = false


## --- Fim da cena: fade, card do dia, próximo dia ---
func _encerrar() -> void:
	if encerrando:
		return
	encerrando = true
	
	GerenciadorPacientes.avancar_fase()
	
	card_dia.text = "Dia %d" % GerenciadorPacientes.fase_atual
	
	var t := create_tween()
	t.tween_property(fade, "modulate:a", 1.0, 0.8)
	t.tween_property(card_dia, "modulate:a", 1.0, 0.6)
	t.tween_interval(1.8)
	t.tween_property(card_dia, "modulate:a", 0.0, 0.5)
	t.tween_callback(func(): get_tree().change_scene_to_file(cena_proxima_dia))
