extends CanvasLayer

@onready var label: Label = $Label
@onready var icono: Sprite2D = $Icono

var ultimo_valor: int = -1

func _ready() -> void:
	actualizar_interfaz(Global.Item_Celular)
	if not Global.item_celular_cambiado.is_connected(actualizar_interfaz):
		Global.item_celular_cambiado.connect(actualizar_interfaz)

func _process(_delta: float) -> void:
	if Global.Item_Celular != ultimo_valor:
		actualizar_interfaz(Global.Item_Celular)

func actualizar_interfaz(cantidad: int) -> void:
	if not label:
		return
	
	if ultimo_valor != -1 and cantidad > ultimo_valor and icono:
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(icono, "scale", Vector2(2.4, 2.4), 0.12)
		tween.tween_property(icono, "scale", Vector2(2.0, 2.0), 0.12)
		
	ultimo_valor = cantidad
	label.text = str(cantidad)
