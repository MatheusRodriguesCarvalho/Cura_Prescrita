extends Node2D

@export_dir var pasta_cenas: String = "res://Arquivos/Cenas VN/"
@export_file("*.tscn") var cena_proxima_dia: String = "res://Scenes/consultorio.tscn"
@export var cena_teste: CenaVN  ## opcional: força uma cena (ignora o filtro por fase)
@export var musica_cena: String = "casa"  ## subpasta em Sons/Musicas; vazio = sem música
@export var cena_abertura: CenaVN  ## opcional: se vazia, mostra só o cartão "Dia 1"
@export var cena_final_bom: CenaVN   ## depois de concluir o último dia
@export var cena_final_ruim: CenaVN  ## ao não atingir a meta de qualquer dia
@export_file("*.tscn") var cena_creditos: String = "res://Scenes/creditos.tscn"

## Duração da digitação = BASE + POR_CHAR * caracteres (100 chars = 3s, 200 chars = 5s)
const DURACAO_BASE := 1.0
const DURACAO_POR_CHAR := 0.02
const COR_FALANDO := Color(1, 1, 1, 1)
const COR_CALADO := Color(0.55, 0.55, 0.6, 1)
const ESCALA_FALANDO := 1.04

const SOM_FALA := "fala"

const ALE := "Ale"
const DESLIZE := 30.0

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
var _escala_base: Dictionary = {} ## nome do personagem -> Vector2 definido no editor

var _esquerda_atual: Sprite2D = null
var _pos_base: Dictionary = {}       ## nome -> posição definida no editor
var _tweens_sprite: Dictionary = {}  ## nome -> Tween (um por personagem)
var modo_abertura := false
var final := ""  ## "" | "bom" | "ruim"

func _ready() -> void:
	modo_abertura = GerenciadorPacientes.abertura_pendente
	GerenciadorPacientes.abertura_pendente = false  ## consome já, para não repetir
	final = GerenciadorPacientes.final_pendente
	GerenciadorPacientes.final_pendente = ""
	_preparar_ui()
	
	for p in personagens.get_children():
		if p is Sprite2D:
			_escala_base[p.name] = p.scale
			_pos_base[p.name] = p.position
			p.hide()
	
	
	## A Alê fica sempre na cena; entra com fade na primeira fala.
	var ale := _achar_personagem(ALE)
	if ale:
		ale.modulate = Color(COR_CALADO.r, COR_CALADO.g, COR_CALADO.b, 0.0)
		ale.show()
	
	if cena_teste:
		cena = cena_teste
	elif final == "bom":
		cena = cena_final_bom
	elif final == "ruim":
		cena = cena_final_ruim
	elif modo_abertura:
		cena = cena_abertura
	else:
		cena = _escolher_cena_do_dia()
	
	
	if cena == null or cena.falas.is_empty():
		_encerrar()   ## sem diálogo: vai direto ao cartão preto
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
	clique_tela.show()
	clique_tela.gui_input.connect(_on_clique_tela)
	
	fade.show()
	fade.modulate.a = 1.0
	
	card_dia.show()
	card_dia.modulate.a = 0.0
	## O card precisa ser desenhado acima do Fade
	card_dia.get_parent().move_child(card_dia, -1)


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
			var nome := arquivo.trim_suffix(".remap").trim_suffix(".import")
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
	var ale := _achar_personagem(ALE)
	
	if falante:
		falante.frame = clampi(fala.expressao, 0, falante.hframes * falante.vframes - 1)
	
	## Fala de outro personagem: ele entra. Fala da Alê ou narração: a esquerda fica vazia.
	if falante != null and falante != ale:
		if falante != _esquerda_atual:
			_trocar_esquerda(falante)
	else:
		_trocar_esquerda(null)
	
	if ale:
		_animar(ale, ale == falante)
	if _esquerda_atual:
		_animar(_esquerda_atual, true)

## Quem estava na esquerda some com fade; o novo entra deslizando.
func _trocar_esquerda(novo: Sprite2D) -> void:
	if _esquerda_atual and _esquerda_atual != novo:
		_sumir(_esquerda_atual)
	_esquerda_atual = novo
	if novo:
		novo.modulate = Color(COR_CALADO.r, COR_CALADO.g, COR_CALADO.b, 0.0)
		novo.position = _pos_base[novo.name] + Vector2(-DESLIZE, 0)
		novo.show()

func _animar(sprite: Sprite2D, ativo: bool) -> void:
	var base_escala: Vector2 = _escala_base[sprite.name]
	var t := _novo_tween(sprite)
	t.set_parallel(true)
	t.tween_property(sprite, "modulate", COR_FALANDO if ativo else COR_CALADO, 0.2)
	t.tween_property(sprite, "scale", base_escala * (ESCALA_FALANDO if ativo else 1.0), 0.2)
	t.tween_property(sprite, "position", _pos_base[sprite.name], 0.25) \
		.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	sprite.z_index = 1 if ativo else 0

func _sumir(sprite: Sprite2D) -> void:
	var t := _novo_tween(sprite)
	t.set_parallel(true)
	t.tween_property(sprite, "modulate:a", 0.0, 0.2)
	t.tween_property(sprite, "position", _pos_base[sprite.name] + Vector2(-DESLIZE, 0), 0.2)
	t.chain().tween_callback(sprite.hide)

## Um tween por personagem: mata o anterior para não brigarem pela mesma propriedade.
func _novo_tween(sprite: Sprite2D) -> Tween:
	var antigo: Tween = _tweens_sprite.get(sprite.name)
	if antigo:
		antigo.kill()
	var t := create_tween()
	_tweens_sprite[sprite.name] = t
	return t


## --- Digitação ---
func _iniciar_digitacao() -> void:
	if tween_texto:
		tween_texto.kill()
	
	var total := label_texto.get_total_character_count()
	label_texto.visible_characters = 0
	digitando = true
	
	GerenciadorAudio.tocar(SOM_FALA)
	
	if total == 0:
		_completar_texto()
		return
	
	var duracao := DURACAO_BASE + DURACAO_POR_CHAR * total
	tween_texto = create_tween()
	tween_texto.tween_property(label_texto, "visible_characters", total, duracao)
	tween_texto.tween_callback(func(): digitando = false)

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
	
	## Final (bom ou ruim): sem "Dia N", vai direto aos créditos.
	if final != "":
		var tf := create_tween()
		tf.tween_property(fade, "modulate:a", 1.0, 1.0)
		tf.tween_callback(func(): get_tree().change_scene_to_file(cena_creditos))
		return
	
	if not modo_abertura:
		GerenciadorPacientes.avancar_fase()
	
	card_dia.text = "Dia %d" % GerenciadorPacientes.fase_atual
	
	var t := create_tween()
	t.tween_property(fade, "modulate:a", 1.0, 0.8)
	t.tween_property(card_dia, "modulate:a", 1.0, 0.6)
	t.tween_interval(1.8)
	t.tween_property(card_dia, "modulate:a", 0.0, 0.5)
	t.tween_callback(func(): get_tree().change_scene_to_file(cena_proxima_dia))
