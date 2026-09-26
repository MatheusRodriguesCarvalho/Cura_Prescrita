extends Node

var remedio_atual: RemedioVisual = null

signal ficha_finalizada
signal novo_paciente_chamado
signal editar_ficha
signal remedio_entregue(correto: bool)


func entregar_remedio(remedio: RemedioVisual, paciente: Paciente) -> void:
	var correto := _remedio_e_correto(remedio, paciente.doenca)
	GerenciadorPacientes.registrar_remedio(paciente.protocolo, remedio.proporcoes, correto)
	remedio_entregue.emit(correto)
	remedio.queue_free()
	remedio_atual = null

func _remedio_e_correto(remedio: RemedioVisual, doenca: Doenca) -> bool:
	if doenca.receita_cura.is_empty():
		## print("1 - doenca não possui cura")
		return false
	## print("1 - doenca possui cura: ", doenca.receita_cura)
	
	if remedio.quantidades.size() != doenca.receita_cura.size():
		## print("2 - Tamanhos divergentes: ", remedio.quantidades.size(), " e ", doenca.receita_cura.size())
		return false
	## print("2 - Tamanhos iguais")
	
	for ingrediente in doenca.receita_cura.keys():
		## print("3 - Ingrediente remedio: ", remedio.quantidades.get(ingrediente, 0))
		## print("3 - Ingrediente cura: ", doenca.receita_cura[ingrediente])
		if remedio.quantidades.get(ingrediente, 0) != doenca.receita_cura[ingrediente]:
			return false
	return true
