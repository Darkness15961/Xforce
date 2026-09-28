extends CanvasLayer

@onready var label: Label = $Label
@onready var icono: Sprite2D = $Icono

func _ready() -> void:
	Global.item_chicha_cambiado.connect(actualizar_interfaz)
	actualizar_interfaz(Global.itemChicha)

func actualizar_interfaz(cantidad: int) -> void:
	if label:
		label.text = str(cantidad)
	if icono and is_inside_tree():
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(icono, "scale", Vector2(2.4, 2.4), 0.12)
		tween.tween_property(icono, "scale", Vector2(2.0, 2.0), 0.12)
