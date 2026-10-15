class_name TutorialPasso
extends Resource

@export var narrador: String = ""
@export_multiline var texto: String = ""
## Caminho do nó a destacar, relativo à raiz da cena atual
@export var alvo: String = ""
## Evento que conclui o passo, enviado por GerenciadorTutorial.notificar("...").
@export var evento_conclusao: String = ""
