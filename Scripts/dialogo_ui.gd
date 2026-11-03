# ui_dialogo.gd
extends Control

@export var historico: VBoxContainer

@export_category("Falas")
@export var cena_fala: PackedScene
@export var estilo_paciente: EstiloFala
@export var estilo_ale: EstiloFala
@export var max_falas := 5

## Altura (px) abaixo do teto em que a fala começa a sumir.
@export var altura_fade := 80.0


func _ready() -> void:
	historico.set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE, Control.PRESET_MODE_MINSIZE)
	historico.grow_vertical = Control.GROW_DIRECTION_BEGIN
	GerenciadorDialogos.falar.connect(_mostrar)
	GerenciadorDialogos.limpar_dialogo.connect(limpar)


func _mostrar(quem: String, texto: String) -> void:
	var estilo := estilo_ale if quem == "Alê" else estilo_paciente
	var fala := cena_fala.instantiate()
	historico.add_child(fala)
	fala.configurar(quem, texto, estilo)


func _process(_delta: float) -> void:
	var teto := global_position.y
	for fala in historico.get_children():
		var topo_rel: float = fala.global_position.y - teto
		if topo_rel + fala.size.y <= 0.0:
			fala.queue_free()  ## já saiu inteira pelo teto
		else:
			fala.definir_alpha_topo(clampf(topo_rel / altura_fade, 0.0, 1.0))

## Opcional: limpa o histórico (ex.: ao chamar um novo paciente).
func limpar() -> void:
	for fala in historico.get_children():
		fala.queue_free()
