extends CanvasLayer

@onready var label: Label = $Label
@onready var icono: Sprite2D = $Icono

var ultimoValor: int = -1

func _ready() -> void:
	actualizar_interfaz(Global.itemChicha)
	if not Global.item_chicha_cambiado.is_connected(actualizar_interfaz):
		Global.item_chicha_cambiado.connect(actualizar_interfaz)

func _process(_delta: float) -> void:
	if Global.itemChicha != ultimoValor:
		actualizar_interfaz(Global.itemChicha)

func actualizar_interfaz(cantidad: int) -> void:
	if not label:
		return
	
	if ultimoValor != -1 and cantidad > ultimoValor and icono:
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
		tween.tween_property(icono, "scale", Vector2(2.4, 2.4), 0.12)
		tween.tween_property(icono, "scale", Vector2(2.0, 2.0), 0.12)
		
	ultimoValor = cantidad
	label.text = str(cantidad)
