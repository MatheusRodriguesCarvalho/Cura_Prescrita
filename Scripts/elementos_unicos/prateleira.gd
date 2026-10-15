extends Node2D

@onready var itens: Array[IngredienteItem] = []
@onready var lista_ingrediente: Node2D = $Ingredientes


func _ready() -> void:
	for filho in lista_ingrediente.get_children():
		if filho is IngredienteItem:
			itens.append(filho)
	atualizar_disponiveis()


func atualizar_disponiveis() -> void:
	var desbloqueados = GerenciadorPacientes.ingredientes_desbloqueados()
	for item in itens:
		var disponivel: bool = item.ingrediente in desbloqueados
		item.visible = disponivel
		item.area.monitorable = disponivel
