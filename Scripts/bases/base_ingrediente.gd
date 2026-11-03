class_name Ingrediente
extends Resource

## Nome exibido no tooltip.
@export var nome: String

## Descrição exibida no tooltip.
@export_multiline var descricao: String

## Sprite usado na prateleira e na instância arrastável.
@export var textura: Texture2D

## Quantos quadros a textura tem na horizontal (spritesheet).
@export var quadros_h: int = 2

## Quadro mostrado na bandeja.
@export var quadro_bandeja: int = 0
