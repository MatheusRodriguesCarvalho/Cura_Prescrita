extends Node

const RESOLUCOES := [Vector2i(1024, 600), Vector2i(1536, 900), Vector2i(2048, 1200), Vector2i(1280, 720), Vector2i(1920, 1080)]
const NOMES := ["1024 × 600", "1536 × 900", "2048 × 1200", "1280 × 720 (16:9)", "1920 × 1080 (16:9)"]
const CAMINHO_CFG := "user://config.cfg"

var indice_atual := 0
var tela_cheia := false


func _ready() -> void:
	carregar()


func aplicar_resolucao(indice: int) -> void:
	indice_atual = clampi(indice, 0, RESOLUCOES.size() - 1)
	var janela := get_window()
	if tela_cheia:
		return  ## em tela cheia o tamanho da janela não vale; é guardado e aplicado ao sair
	janela.mode = Window.MODE_WINDOWED
	var util := DisplayServer.screen_get_usable_rect().size
	var alvo: Vector2i = RESOLUCOES[indice_atual]
	var fator := minf(1.0, minf(float(util.x) / alvo.x, float(util.y) / alvo.y))
	janela.size = Vector2i(alvo * fator)
	janela.move_to_center()


func definir_tela_cheia(ligado: bool) -> void:
	tela_cheia = ligado
	if ligado:
		get_window().mode = Window.MODE_FULLSCREEN
	else:
		aplicar_resolucao(indice_atual)


func salvar() -> void:
	var cfg := ConfigFile.new()
	cfg.load(CAMINHO_CFG)  ## preserva outras seções, se existirem
	cfg.set_value("video", "resolucao", indice_atual)
	cfg.set_value("video", "tela_cheia", tela_cheia)
	cfg.save(CAMINHO_CFG)


func carregar() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(CAMINHO_CFG) != OK:
		return
	indice_atual = cfg.get_value("video", "resolucao", 0)
	tela_cheia = cfg.get_value("video", "tela_cheia", false)
	definir_tela_cheia(tela_cheia)
