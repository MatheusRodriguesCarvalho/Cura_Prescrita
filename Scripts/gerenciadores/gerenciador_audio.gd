extends Node

@export var eventos: Array[EventoSonoro] = []
@export_dir var pasta_eventos: String = "res://Sons/EventosSonoros/"
@export_dir var pasta_musicas: String = "res://Sons/Musicas/"

## --- Efeitos sonoros ---
const TAMANHO_POOL := 6
var _players: Array[AudioStreamPlayer] = []
var _proximo := 0
var _mapa_eventos: Dictionary = {}

## --- Música ---
var _player_musica_a: AudioStreamPlayer
var _player_musica_b: AudioStreamPlayer
var _tocando_a := true
var _mapa_musicas: Dictionary = {}    # nome_cena -> Array[AudioStream]
var _cena_musical_atual := ""
var _dia_por_cena: Dictionary = {}    # nome_cena -> fase em que foi sorteada
var _stream_por_cena: Dictionary = {} # nome_cena -> AudioStream escolhido




func _ready() -> void:
	for i in TAMANHO_POOL:
		var player := AudioStreamPlayer.new()
		player.bus = "Efeitos"
		add_child(player)
		_players.append(player)
	
	_player_musica_a = AudioStreamPlayer.new()
	_player_musica_a.bus = "Musica"
	add_child(_player_musica_a)
	
	_player_musica_b = AudioStreamPlayer.new()
	_player_musica_b.bus = "Musica"
	_player_musica_b.volume_db = -80.0
	add_child(_player_musica_b)
	
	_carregar_eventos()
	_carregar_musicas()

## --- Efeitos sonoros ---
func _carregar_eventos() -> void:
	var dir:= DirAccess.open(pasta_eventos)
	if dir == null:
		print("Não localizado")
		return
	
	dir.list_dir_begin()
	
	var arquivo := dir.get_next()
	while arquivo != "":
		if not dir.current_is_dir() and arquivo.get_extension() == "tres":
			var caminho := pasta_eventos.path_join(arquivo)
			var evento := load(caminho) as EventoSonoro
			if evento:
				_mapa_eventos[evento.nome] = evento.variacoes
		arquivo = dir.get_next()
	
	dir.list_dir_end()
	
	print("Eventos sonoros carregados: ", _mapa_eventos.size())

func tocar(nome: String) -> void:
	var variacoes: Array = _mapa_eventos.get(nome, [])
	if variacoes.is_empty():
		print("Nome %s não encontrado" % nome)
		return
	
	var stream: AudioStream = variacoes[randi() % variacoes.size()]
	var player := _players[_proximo]
	player.stream = stream
	player.play()
	_proximo = (_proximo + 1) % TAMANHO_POOL

## --- Música ---

func _carregar_musicas() -> void:
	var dir := DirAccess.open(pasta_musicas)
	if dir == null:
		push_warning("Pasta de músicas não localizada: " + pasta_musicas)
		return
	
	dir.list_dir_begin()
	var arquivo := dir.get_next()
	while arquivo != "":
		if dir.current_is_dir() and arquivo != "." and arquivo != "..":
			var subpasta := pasta_musicas.path_join(arquivo)
			_mapa_musicas[arquivo] = _carregar_streams_da_pasta(subpasta)
		arquivo = dir.get_next()
	dir.list_dir_end()
	
	print("Conjuntos de música carregados: ", _mapa_musicas.size())

func _carregar_streams_da_pasta(caminho: String) -> Array[AudioStream]:
	var resultado: Array[AudioStream] = []
	var dir := DirAccess.open(caminho)
	if dir == null:
		return resultado
	dir.list_dir_begin()
	var arquivo := dir.get_next()
	while arquivo != "":
		if not dir.current_is_dir():
			var stream := load(caminho.path_join(arquivo)) as AudioStream
			if stream:
				resultado.append(stream)
		arquivo = dir.get_next()
	dir.list_dir_end()
	return resultado







func tocar_musica_cena(nome_cena: String, trava_por_dia: bool = false) -> void:
	if nome_cena == _cena_musical_atual:
		return
	
	var proxima: AudioStream
	
	if trava_por_dia:
		var dia_atual := GerenciadorPacientes.fase_atual
		if _dia_por_cena.get(nome_cena, -1) == dia_atual and _stream_por_cena.has(nome_cena):
			proxima = _stream_por_cena[nome_cena]
		else:
			proxima = _sortear_faixa(nome_cena)
			if proxima == null:
				return
			_dia_por_cena[nome_cena] = dia_atual
			_stream_por_cena[nome_cena] = proxima
	else:
		proxima = _sortear_faixa(nome_cena)
		if proxima == null:
			return
	
	_cena_musical_atual = nome_cena
	_trocar_com_crossfade(proxima)

func _sortear_faixa(nome_cena: String) -> AudioStream:
	var opcoes: Array = _mapa_musicas.get(nome_cena, [])
	if opcoes.is_empty():
		push_warning("Nenhuma música encontrada para: " + nome_cena)
		return null
	return opcoes[randi() % opcoes.size()]

func _trocar_com_crossfade(proxima: AudioStream) -> void:
	var player_entrando := _player_musica_b if _tocando_a else _player_musica_a
	var player_saindo := _player_musica_a if _tocando_a else _player_musica_b
	
	player_entrando.stream = proxima
	player_entrando.volume_db = -80.0
	player_entrando.play()
	
	var tween := create_tween().set_parallel(true)
	tween.tween_property(player_entrando, "volume_db", 0.0, 1.5)
	tween.tween_property(player_saindo, "volume_db", -80.0, 1.5)
	tween.chain().tween_callback(player_saindo.stop)
	
	_tocando_a = not _tocando_a
