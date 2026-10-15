## Estrutura base de uma doença, e o que ela irá causar no paciente.
class_name Doenca
extends Resource

@export_category("Guia Médico")
## Código de Identificação pela Gestão de Saúde Humana.
@export var id: String
## Nome Comum atribuido à Doença.
@export var nome: String
## Nome(s) Populare(s) atribuido à Doença.
@export var nome_popular: Array[String]
@export_range(1, 5) var risco: int
## Texto descritivo e educativo sobre a doença, exibido no guia.
@export_multiline var descricao: String
## Categoria da doença, usada para organizar/filtrar o guia por tipo.
@export_enum("Respiratória", "Digestiva", "Infecciosa", "Cardiovascular", "Outra") var categoria: String
## Sintomas apresentados pelo paciente, usada para exibição e/ou diagnóstico.
@export var sintomas: Array[String]

## Valores Absolutos que representam a media da Doença para a medição
@export_category("Medições")
@export_range(80, 190, 1) var med_pressao_sistolica: float = 120
@export_range(50, 130, 1) var med_pressao_diastolica: float = 80
@export_range(30, 45, 0.1) var med_temperatura: float = 36.5
@export_range(0, 110, 0.5) var med_saturacao: float = 96

@export_category("Progressão")
## Fase mínima em que esta doença pode aparecer
@export var fase: int = 1

@export_category("Tratamento")
## Maximo total de 8 ingredientes
@export var receita_cura: Dictionary[Ingrediente, int] = {}
@export var tolerancia_receita: float = 2.0

@export_category("Sintomas")
@export var falas_sintomas: Array[String] = [
	"Acho que estou com %s",
	"Estou sentindo %s",
	"Basicamente %s",
]


const REACAO_CERTA_PADRAO := ["Nossa, muito obrigada!", "Já estou me sentindo melhor, obrigada!"]
const REACAO_ERRADA_PADRAO := ["Doutora, esse remédio não caiu muito bem...", "Hm... acho que piorou um pouco."]

@export_group("Reação ao remédio")
@export var falas_remedio_certo: Array[String] = []
@export var falas_remedio_errado: Array[String] = []


## --- DIALOGO ---
func fala_sintoma_aleatoria() -> String:
	if falas_sintomas.is_empty():
		return "Não sei ao certo o que estou sentindo..."
	var template: String = falas_sintomas[randi() % falas_sintomas.size()]
	var sintoma: String = sintomas[randi() % sintomas.size()]
	return template % sintoma


func print_receita() -> String:
	var linhas := [""]
	
	for ingrediente in receita_cura.keys():
		
		var nome: String = str(ingrediente.nome)
		var valor: int = receita_cura.get(ingrediente, 0)
		linhas.append(" - %s: %d" % [nome, valor])
	
	return "\n".join(linhas)


func fala_reacao(correto: bool) -> String:
	var lista: Array = falas_remedio_certo if correto else falas_remedio_errado
	if lista.is_empty():
		lista = REACAO_CERTA_PADRAO if correto else REACAO_ERRADA_PADRAO
	return lista[randi() % lista.size()]

## --- CALCULOS COM MARGEM ---
## Calcula uma faixa aproximada [valor - margem, valor + margem].
## Função auxiliar interna, usada pelas faixas específicas abaixo.
func _faixa(valor: float, margem: float) -> Vector2:
	return Vector2(valor - margem, valor + margem)

func faixa_temperatura(margem: float = 0.35) -> Vector2:
	return _faixa(med_temperatura, margem)

func faixa_pressao_sistolica(margem: float = 8.0) -> Vector2:
	return _faixa(med_pressao_sistolica, margem)

func faixa_pressao_diastolica(margem: float = 6.0) -> Vector2:
	return _faixa(med_pressao_diastolica, margem)

func faixa_saturacao(margem: float = 3.0) -> Vector2:
	return _faixa(med_saturacao, margem)
