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
		return false
	
	for ingrediente: Ingrediente in doenca.receita_cura.keys():
		var esperado: float = doenca.receita_cura[ingrediente]
		var obtido: float = remedio.proporcoes.get(ingrediente, 0.0)
		if abs(obtido - esperado) > 0:
			return false
	
	for ingrediente in remedio.proporcoes.keys():
		if not doenca.receita_cura.has(ingrediente):
			return false
	
	return true
