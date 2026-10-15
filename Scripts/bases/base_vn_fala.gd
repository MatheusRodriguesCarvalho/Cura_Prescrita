# fala_vn.gd
class_name FalaVN
extends Resource

enum Personagem { Ale, Laila, Franco, Narrador, Pessoa }

## @export var nome: String
@export var nome: Personagem
@export_multiline var texto: String
@export var expressao: int = 0  ## número do frame no spritesheet do personagem

func get_nome() -> String:
	if nome == Personagem.Narrador:
		return ""
	if nome == Personagem.Pessoa:
		return "Alguém"
	return Personagem.keys()[nome]
