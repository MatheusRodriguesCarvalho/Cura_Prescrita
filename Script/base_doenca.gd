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
## Nível de periculosidade da Doença: 1 (baixo), 2 (moderado), 3 (alto/crítico).
@export_range(1, 3) var risco: int
## Texto descritivo e educativo sobre a doença, exibido no guia.
@export_multiline var descricao: String
## Categoria da doença, usada para organizar/filtrar o guia por tipo.
@export_enum("Respiratória", "Digestiva", "Infecciosa", "Cardiovascular", "Outra") var categoria: String
## Sintomas apresentados pelo paciente, usada para exibição e/ou diagnóstico.
@export var sintomas: Array[String]

## Valores Absolutos que representam a media da Doença para a medição
@export_category("Medições")

## Pressão Arterial Sistolica. Variações de valores vão de 80 até 190
@export_range(80, 190, 5) var med_pressao_sistolica: float = 120
## Pressão Arterial Diastolica. Variações de valores vão de 80 até 190
@export_range(50, 130, 4) var med_pressao_diastolica: float = 80
## Temperatura corporal do paciente em °C. Acima de 37.8 já é considerado febre.
@export_range(30, 45) var med_temperatura: float = 36.5
## Saturação do sangue do paciente. Varia de 0% a 100%, acima de 95 é normal, abaixo de 90 é preocupante.
@export_range(0, 110, 2.5) var med_saturacao: float = 96

@export_category("Progressão")
## Fase mínima em que esta doença pode aparecer
@export var fase: int = 1


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
	
