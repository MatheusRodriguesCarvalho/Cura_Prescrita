# cena_vn.gd
class_name CenaVN
extends Resource

@export var id: String
@export var fase: int = 1  # em que dia essa cena aparece
@export var fundo: Texture2D
@export var falas: Array[FalaVN] = []
