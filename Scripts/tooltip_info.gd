# Autoload
extends Node


signal mostrar(texto: String, estilo: String)
signal aviso(texto: String)
signal esconder


## Liga um tooltip a uma Area2D ou Control com uma linha.
## texto: Callable chamado no momento do hover; se devolver "", nada é mostrado.
## Ex.: TooltipInfo.vincular($Area2D, func(): return ingrediente.nome, "item")
func vincular(alvo: Node, texto: Callable, estilo: String = "item") -> void:
	alvo.mouse_entered.connect(func():
		var t: String = texto.call()
		if t != "":
			mostrar.emit(t, estilo))
	alvo.mouse_exited.connect(func(): esconder.emit())
