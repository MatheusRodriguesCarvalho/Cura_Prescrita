extends Node

enum Modo {CRONOMETRO, ESTAMINA}

@export var modo: Modo = Modo.CRONOMETRO
@export var tempo_total: float = 60.0

@export var estamina_total: float = 100.0
@export var custo_acao_padrao: float = 6.0

var valor_atual: float
var fase_ativa: bool = false

signal tempo_atualizado(atual: float, total: float)
signal tempo_esgotado

func iniciar_fase() -> void:
	valor_atual = _total_atual()
	fase_ativa = true
	tempo_atualizado.emit(valor_atual, _total_atual())
	##print("Tempo Inicial: ", valor_atual)

func encerrar_fase() -> void:
	fase_ativa = false

func _process(delta: float) -> void:
	if not fase_ativa or modo != Modo.CRONOMETRO:
		return
	_consumir(delta)

func registrar_acao(custo: float = -1.0) -> void:
	if not fase_ativa or modo != Modo.ESTAMINA:
		return
	var custo_real := custo if custo >= 0.0 else custo_acao_padrao
	_consumir(custo_real)

func _consumir(quantidade: float) -> void:
	valor_atual = max(0.0, valor_atual - quantidade)
	tempo_atualizado.emit(valor_atual, _total_atual())
	if valor_atual <= 0.0:
		_esgotar()
	##print("Tempo Corrente: ", valor_atual)

func _total_atual() -> float:
	return tempo_total if modo == Modo.CRONOMETRO else estamina_total

func _esgotar() -> void:
	fase_ativa = false
	tempo_esgotado.emit()
