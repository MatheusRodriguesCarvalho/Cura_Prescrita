extends Node

## Listagem de todas as doenças criadas
@export_dir var pasta_doencas: String = "res://Doencas/"
var lista_doencas: Array[Doenca]

## Cenas de pacientes predefinidos, cada uma já com sprite/nome/protocolo/idade prontos.
@export_dir var pasta_pacientes: String = "res://Pacientes/"
var pacientes_predefinidos: Array[PackedScene] = []

@export_dir var pasta_noticias: String = "res://Noticias/"
@export var lista_noticias: Array[Noticia]


## Dia atual do jogo (unificado: controla tanto doenças quanto regras).
var fase_atual: int = 1

## Doenças já selecionadas, mapeadas por id -> fase em que foram sorteadas.
var doencas_desbloqueadas: Dictionary = {}

## Pacientes atualmente ativos, indexados por protocolo.
var pacientes_ativos: Dictionary = {}

var registros_do_dia: Dictionary = {}


@export_category("Pontuação")
@export var pontos_diagnostico_correto: float = 60.0
@export var pontos_medicao_correta: float = 10.0
@export var tolerancia_temperatura: float = 0.3
@export var tolerancia_pressao: float = 4.0
@export var tolerancia_saturacao: float = 2.0





func _ready() -> void:
	_carregar_doencas()
	_selecionar_novas_doencas()
	_carregar_pacientes()
	_carregar_noticias()


## --- Carregar Informações das Pastas ---
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
	var arquivo := dir.get_next()
	while arquivo != "":
		if not dir.current_is_dir() and arquivo.get_extension() == "tres":
			var caminho := pasta_doencas.path_join(arquivo)
			var doenca := load(caminho) as Doenca
			if doenca:
				lista_doencas.append(doenca)
		arquivo = dir.get_next()
	dir.list_dir_end()
	
	print("Doenças Carregadas: ", lista_doencas.size())

func _carregar_noticias() -> void:
	var dir := DirAccess.open(pasta_noticias)
	if dir == null:
		print("Pasta Noticias não localizada")
		return
	
	dir.list_dir_begin()
	var arquivo := dir.get_next()
	while arquivo != "":
		if not dir.current_is_dir() and arquivo.get_extension() == "tres":
			var caminho := pasta_noticias.path_join(arquivo)
			var noticia := load(caminho) as Noticia
			if noticia:
				lista_noticias.append(noticia)
		arquivo = dir.get_next()
	dir.list_dir_end()


## --- Doenças ---
func _selecionar_novas_doencas() -> void:
	var pool := lista_doencas.filter(func(d):
		## Não Permite que doenças fora do escopo da fase seja catalogada
		return d.fase <= fase_atual and not doencas_desbloqueadas.has(d.id)
	)
	
	if pool.is_empty():
		print("Nenhuma doença nova disponível para a fase ", fase_atual)
		return
	
	## Garante que de 1 a 2 doenças sejam adicionadas por dia
	var quantidade := randi_range(1, min(2, pool.size()))
	pool.shuffle()
	for i in quantidade:
		doencas_desbloqueadas[pool[i].id] = fase_atual

func doencas_ativas() -> Array[Doenca]:
	return lista_doencas.filter(func(d): return doencas_desbloqueadas.has(d.id))


## --- Dias ---
func avancar_fase() -> void:
	fase_atual += 1
	_selecionar_novas_doencas()


## --- Noticias ---
func noticia_do_dia(dia: int) -> Noticia:
	for noticia in lista_noticias:
		if noticia.dia == dia:
			return noticia
	return null

func noticias_anteriores(dia: int) -> Array[Noticia]:
	var anteriores := lista_noticias.filter(func(n): return n.dia < dia)
	anteriores.sort_custom(func(a, b): return a.dia < b.dia)
	return anteriores


## --- Paciente e Protocolo ---
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
	paciente.menu_dialogo = local.get_tree().current_scene.get_node("CanvasLayer/MenuDialogo")
	_registrar_info_real(paciente)
	pacientes_ativos [paciente.protocolo] = paciente
	GerenciadorTempo.registrar_acao(15.0)
	GerenciadorAla.novo_paciente_chamado.emit()
	GerenciadorDialogos.apresentar_paciente(paciente)
	
	return paciente

func busca_por_protocolo(protocolo: String) -> Paciente:
	return pacientes_ativos.get(protocolo, null)

func liberar_paciente(protocolo: String) -> void:
	pacientes_ativos.erase(protocolo)

func _registrar_info_real(paciente: Paciente) -> void:
	registros_do_dia[paciente.protocolo] = {
		"info_real": {
			"doenca": paciente.doenca,
			"temperatura": paciente.med_temperatura,
			"pressao_sistolica": paciente.med_pressao_sistolica,
			"pressao_diastolica": paciente.med_pressao_diastolica,
			"saturacao": paciente.med_saturacao,
		},
		"info_ficha": {},
	}


## --- Ficha e Pontuacao ---
func registrar_ficha(protocolo: String, ficha: Dictionary) -> void:
	if registros_do_dia.has(protocolo):
		registros_do_dia[protocolo]["info_ficha"] = ficha

func calcular_pontuacao(protocolo: String) -> float:
	if not registros_do_dia.has(protocolo):
		return 0.0
	
	var registro: Dictionary = registros_do_dia[protocolo]
	var real: Dictionary = registro["info_real"]
	var ficha: Dictionary = registro["info_ficha"]
	var doenca: Doenca = real["doenca"]
	
	var pontos := 0.0
	
	if _diagnosticoo_correto(ficha.get("condicao", ""), doenca):
		pontos += pontos_diagnostico_correto
	else:
		pontos -= 10.0 * doenca.risco
	
	
	var info_remedio: Dictionary = registro.get("remedio", {})
	if info_remedio.get("correto", false):
		pontos += 30.0
	else:
		pontos -= 15.0 * doenca.risco
	
	
	if _valor_proximo(ficha.get("temperatura", ""), real["temperatura"], tolerancia_temperatura):
		pontos += pontos_medicao_correta
	
	if _pressao_proxima(ficha.get("pressao", ""), real["pressao_sistolica"], real["pressao_diastolica"]):
		pontos += pontos_medicao_correta
	
	if _valor_proximo(ficha.get("saturacao", ""), real["saturacao"], tolerancia_saturacao):
		pontos += pontos_medicao_correta
	return pontos

func _diagnosticoo_correto(texto: String, doenca: Doenca) -> bool:
	var alvo := _normalizar(texto)
	if alvo == _normalizar(doenca.nome):
		return true
	return false

func _normalizar(texto: String) -> String:
	var resultado := texto.strip_edges().to_lower()
	var acentuados := ""
	var simples := ""
	
	for letra in acentuados.length():
		resultado = resultado.replace(acentuados[letra], simples[letra])
	return resultado

## --- Tolerancia ---
func _valor_proximo(texto: String, valor_real: float, tolerancia: float) -> bool:
	if not texto.is_valid_float():
		return false
	return abs(texto.to_float() - valor_real) <= tolerancia

func _pressao_proxima(texto: String, sistolica_real: float, diastolica_real: float) -> bool:
	var partes := texto.split("/")
	if partes.size() != 2 or not partes[0].is_valid_float() or not partes[1].is_valid_float():
		return false
	var sist_ok: bool = abs(partes[0].to_float() - sistolica_real) <= tolerancia_pressao
	var diast_ok: bool = abs(partes[1].to_float() - diastolica_real) <= tolerancia_pressao
	return sist_ok and diast_ok


func cacular_pontuacao_total_do_dia() -> float:
	var total := 0.0
	for protocolo in registros_do_dia.keys():
		total += calcular_pontuacao(protocolo)
	return total

func registrar_remedio(protocolo: String, proporcoes: Dictionary, correto: bool) -> void:
	if registros_do_dia.has(protocolo):
		registros_do_dia[protocolo]["remedio"] = {"proporcoes": proporcoes, "correto": correto}
