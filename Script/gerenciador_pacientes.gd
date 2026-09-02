extends Node

## Listagem de todas as doenças criadas
@export_dir var pasta_doencas: String = "res://Doencas/"
var lista_doencas: Array[Doenca]

## Cenas de pacientes predefinidos, cada uma já com sprite/nome/protocolo/idade prontos.
@export_dir var pasta_pacientes: String = "res://Pacientes/"
var pacientes_predefinidos: Array[PackedScene] = []

## Dia atual do jogo (unificado: controla tanto doenças quanto regras).
var fase_atual: int = 1

## Doenças já selecionadas, mapeadas por id -> fase em que foram sorteadas.
var doencas_desbloqueadas: Dictionary = {}

## Pacientes atualmente ativos, indexados por protocolo.
var pacientes_ativos: Dictionary = {}

func _ready() -> void:
	_carregar_doencas()
	_selecionar_novas_doencas()
	_carregar_pacientes()

func _carregar_pacientes() -> void:
	var dir := DirAccess.open(pasta_pacientes)
	if dir == null:
		print("Pasta de pacientes não localizada")
		return
	dir.list_dir_begin()
	var arquivo := dir.get_next()
	while arquivo != "":
		if not dir.current_is_dir() and arquivo.get_extension() == "tscn":
			var caminho := pasta_pacientes.path_join(arquivo)
			var cena := load(caminho) as PackedScene
			if cena:
				pacientes_predefinidos.append(cena)
		arquivo = dir.get_next()
	dir.list_dir_end()
	print("Pacientes carregados: ", pacientes_predefinidos.size())

func _carregar_doencas() -> void:
	var dir := DirAccess.open(pasta_doencas)
	if dir == null:
		print("Pasta não localizada")
		return
	
	dir.list_dir_begin()
	var arquivo :=dir.get_next()
	while arquivo != "":
		if not dir.current_is_dir() and arquivo.get_extension() == "tres":
			var caminho := pasta_doencas.path_join(arquivo)
			var doenca := load(caminho) as Doenca
			if doenca:
				lista_doencas.append(doenca)
		arquivo = dir.get_next()
	dir.list_dir_end()
	
	print("Doenças Carregadas: ", lista_doencas.size())

func _selecionar_novas_doencas() -> void:
	var pool := lista_doencas.filter(func(d):
		return d.fase <= fase_atual and not doencas_desbloqueadas.has(d.id)
	)
	
	if pool.is_empty():
		print("Nenhuma doença nova disponível para a fase ", fase_atual)
		return
	
	var quantidade := randi_range(1, min(2, pool.size()))
	pool.shuffle()
	for i in quantidade:
		doencas_desbloqueadas[pool[i].id] = fase_atual

## Retorna as doenças já disponíveis no dia atual.
func doencas_ativas() -> Array[Doenca]:
	return lista_doencas.filter(func(d): return doencas_desbloqueadas.has(d.id))

func avancar_fase() -> void:
	fase_atual += 1
	_selecionar_novas_doencas()

## Instancia um paciente predefinido, sorteia uma doença ativa e a aplica.
func chamar_paciente(local: Node, indice: int = -1) -> Paciente:
	if pacientes_predefinidos.is_empty():
		push_warning("Nunhum paciente predefinido configurado")
		return null
	
	var cena: PackedScene = pacientes_predefinidos[indice] if indice != -1 else pacientes_predefinidos[randi() % pacientes_predefinidos.size()]
	
	var paciente: Paciente = cena.instantiate()
	local.add_child(paciente)
	
	var ativas := doencas_ativas()
	if ativas.is_empty():
		push_warning("Nenhuma Doença ativa para o dia atual")
		return null
	
	## TODO
	## var doenca_sorteada: Doenca = ativas[randi() % ativas.size()]
	var doenca_sorteada: Doenca = ativas[randi_range(0, ativas.size() - 1)]
	
	paciente.apliar_doenca(doenca_sorteada)
	
	pacientes_ativos [paciente.protocolo] = paciente
	
	return paciente

func busca_por_protocolo(protocolo: String) -> Paciente:
	return pacientes_ativos.get(protocolo, null)

func liberar_paciente(protocolo: String) -> void:
	pacientes_ativos.erase(protocolo)
