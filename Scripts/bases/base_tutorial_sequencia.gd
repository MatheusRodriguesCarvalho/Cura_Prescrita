class_name TutorialSequencia
extends Resource

## Identificador único (ex.: "dia0", "ala_medicacao"). Usado para lembrar o que já foi visto.
@export var id: String = ""
@export var pausar_tempo: bool = true
@export var passos: Array[TutorialPasso] = []
