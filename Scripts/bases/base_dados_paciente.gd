class_name DadosPaciente
extends Resource

@export_category("Cadastro")
## Identificação única do paciente
@export var protocolo: String
## Nome do Paciente
@export var nome: String
## Idade do Paciente
@export var idade: int

@export_category("Cadastro (cosmético)")
@export var tipo_sanguineo: String = "AB+"
@export var implantes: String = "Leitor neural / Joelho articulado."
@export var transplantes: String = "Figado AB+ / Córnea."

@export var textura: Texture2D

@export var falas_vida_perguntas: Array[String] = [
	"Como está?",
	]
@export var falas_vida_respostas: Array[String] = [
	"Bem ruim",
]
