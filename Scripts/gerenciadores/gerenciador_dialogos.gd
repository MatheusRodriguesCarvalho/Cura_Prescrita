## Gerenciador de Dialogos:
	## Contem frases de apresentação, onde nelas poderá constar o numero de protocolo
	## Contem a resposta ao pedido do protocolo, a primeira opção do menu
	## 

extends Node

var falas_apresentacao := [
	{"pergunta": "Bom dia, pode me informar o protocolo?", "resposta": "Bom dia, o protocolo é %s", "informa_protocolo": true},
	{"pergunta": "Olá, me informe o protocolo?", "resposta": "Olá, o protocolo é o seguinte: %s", "informa_protocolo": true},
	{"pergunta": "Bom dia, como vai? Pode me informar o protocolo?", "resposta": "Acho que esqueci, doutora...", "informa_protocolo": false},
	{"pergunta": "Bom dia, o que te traz aqui?", "resposta": "Dôtora, to bem não...", "informa_protocolo": false},
]

var falas_protocolo_avulso := [
	"O protocolo é %s.",
	"Aqui está: %s.",
]

var tempo_exibicao: float = 5.0
var tempo_exibicao_2: float = tempo_exibicao / 2

## Emit para o UI_DIALOGO
signal falar(quem: String, texto: String)
signal informar(texto: String)


func apresentar_paciente(paciente: Paciente) -> void:
	await get_tree().create_timer(0.5).timeout
	var par: Dictionary = falas_apresentacao[randi() % falas_apresentacao.size()]
	falar.emit("Alê", par["pergunta"])
	await get_tree().create_timer(tempo_exibicao_2).timeout
	if par["informa_protocolo"]:
		falar.emit("Paciente", par["resposta"] % paciente.protocolo)
	else:
		falar.emit("Paciente", par["resposta"])


func pedir_protocolo(paciente: Paciente) -> void:
	var resposta: String = falas_protocolo_avulso[randi() % falas_protocolo_avulso.size()]
	falar.emit(paciente.nome, resposta % paciente.protocolo)
