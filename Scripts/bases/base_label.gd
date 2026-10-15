class_name EstiloLabel
extends Resource

@export_category("Texto")
@export var cor_texto: Color = Color.WHITE
@export var tamanho_fonte: int = 16
@export var cor_contorno: Color = Color.BLACK
@export var espessura_contorno: int = 2

@export_category("Disposição")
## Largura máxima antes de quebrar linha. 0 = sem limite.
@export var largura_maxima: float = 100.00
@export var alinhamento_horizontal: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT
@export var autowrap: bool = false

@export_category("Fundo/Padding")
@export var cor_fundo: Color = Color(0, 0, 0, 0.6)
@export var padding: Vector4 = Vector4(8, 4, 8, 4)  # esquerda, cima, direita, baixo

func aplicar(container: PanelContainer, label: Label) -> void:
	label.add_theme_color_override("font_color", cor_texto)
	label.add_theme_font_size_override("font_size", tamanho_fonte)
	label.add_theme_color_override("font_outline_color", cor_contorno)
	label.add_theme_constant_override("outline_size", espessura_contorno)
	
	label.horizontal_alignment = alinhamento_horizontal
	label.autowrap_mode = TextServer.AUTOWRAP_WORD if autowrap else TextServer.AUTOWRAP_OFF
	if largura_maxima > 0:
		label.custom_minimum_size.x = largura_maxima
	
	var stylebox := StyleBoxFlat.new()
	stylebox.bg_color = cor_fundo
	stylebox.content_margin_left = padding.x
	stylebox.content_margin_top = padding.y
	stylebox.content_margin_right = padding.z
	stylebox.content_margin_bottom = padding.w
	container.add_theme_stylebox_override("panel", stylebox)
