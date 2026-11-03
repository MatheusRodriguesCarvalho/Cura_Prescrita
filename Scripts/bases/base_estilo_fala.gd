class_name EstiloFala
extends Resource

enum Lado { ESQUERDA, DIREITA }
@export var lado: Lado = Lado.ESQUERDA
@export var estilo_balao: EstiloLabel   ## usado no texto
@export var estilo_nome: EstiloLabel    ## usado no nome (pode ser null = sem nome)
@export var duracao_extra := 0.0        ## opcional: fala que fica mais tempo
