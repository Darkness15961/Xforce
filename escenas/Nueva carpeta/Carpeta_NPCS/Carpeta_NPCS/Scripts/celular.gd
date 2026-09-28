extends Area2D

var puedeInteractuar: bool = false

#region Alias de compatibilidad
var puede_Interactuar: bool:
	get: return puedeInteractuar
	set(val): puedeInteractuar = val
#endregion

func _process(_delta: float) -> void:
	if puedeInteractuar and Input.is_action_just_pressed("Interact"):
		Global.agregar_celular(1)
		queue_free()

func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.is_in_group("Jugador"):
		puedeInteractuar = true

func _on_body_shape_exited(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.is_in_group("Jugador"):
		puedeInteractuar = false
