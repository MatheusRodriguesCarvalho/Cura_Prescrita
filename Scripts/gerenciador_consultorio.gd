extends Node2D

var paciente_atual: Paciente = null
var atendimento_concluido: bool = false

func _ready():
	GerenciadorTempo.tempo_esgotado.connect(_on_tempo_esgotado)
	GerenciadorTempo.iniciar_fase()

## -- TEMPO E TELAS --
func _on_tempo_esgotado() -> void:
	print("Time Out, fim da Fase")
	# TODO: Transição, tela de estatisticas do dia e troca de Cena
