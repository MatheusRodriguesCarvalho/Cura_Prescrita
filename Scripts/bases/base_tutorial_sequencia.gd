class_name TutorialSequencia
extends Resource

## Identificador único (ex.: "dia1"). Usado para lembrar o que já foi visto.
@export var id: String = ""
## Congela cronômetro/estamina enquanto a sequência roda.
@export var pausar_tempo: bool = true
## Quem fala e como aparece, quando o passo não define.
@export var narrador_padrao: String = "Cíntia"
@export var retrato_padrao: Texture2D
@export var passos: Array[TutorialPasso] = []
