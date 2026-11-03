class_name TutorialPasso
extends Resource
## Um passo do tutorial. Tem até duas partes:
##  - ESPERA: o nó "alvo" brilha até o jogador clicar nele (capturar_clique)
##    ou até o jogo avisar um evento (evento_conclusao).
##  - FALA: a personagem aparece com o "texto" e some quando o jogador clica.
## Por padrão a espera vem primeiro e a fala depois (narrar_primeiro desliga isso).

## Vazio = usa o narrador padrão da sequência (ex.: "Cíntia").
@export var narrador: String = ""
## Vazio = o passo não tem fala.
@export_multiline var texto: String = ""
## Vazio = usa o retrato padrão da sequência.
@export var retrato: Texture2D

## Caminho do nó que brilha, relativo à raiz da cena (ex.: "Consultorio/Mundo/Mesa/Teclado").
@export var alvo: String = ""
## O clique no alvo é "engolido": só avança o tutorial, não executa a ação de verdade.
@export var capturar_clique: bool = false
## Evento que conclui a espera (enviado por GerenciadorTutorial.notificar("...")).
@export var evento_conclusao: String = ""
## true = a personagem fala antes; só depois vem a espera (brilho + evento).
@export var narrar_primeiro: bool = false
