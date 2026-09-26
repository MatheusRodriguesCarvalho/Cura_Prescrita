extends Control

@onready var noticia_atual: RichTextLabel = $DivRegras/NoticiaAtual
@onready var noticias_anteriores: RichTextLabel = $DivRegras/Scroll/NoticiasAnteriores



func popular() -> void:
	var atual: Noticia = GerenciadorPacientes.noticia_do_dia(GerenciadorPacientes.fase_atual)
	noticia_atual.text = "%s\n\n%s" % [atual.chamada, atual.texto] if atual else "Sem Noticias Hoje"
	
	var linhas: Array[String] = []
	for noticia in GerenciadorPacientes.noticias_anteriores(GerenciadorPacientes.fase_atual):
		linhas.append("Dia %d: %s" % [noticia.dia, noticia.chamada])
	noticias_anteriores.text = "\n".join(linhas)


func _on_rbotao_ir_pressed() -> void:
	get_parent().get_parent().abrir_sumario_doencas()


func _on_r_botao_voltar_pressed() -> void:
	get_parent().get_parent().fechar()
