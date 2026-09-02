## Canal de comunicação entre as ferramentas de diagnóstico (Node2D) e o
## popup de resultado (UI). Desacopla os dois: a ferramenta não precisa
## saber onde o popup está na árvore, e vice-versa.
extends Node

## Emitido quando uma ferramenta termina uma leitura e quer exibir o resultado.
signal solicitado(resultado: String)

## Emitido quando o popup deve ser escondido.
signal escondido
