extends Area2D

var puede_Interactuar: bool = false

func _process(_delta: float) -> void:
	if puede_Interactuar and Input.is_action_just_pressed("Interact"):
		Global.agregar_celular(1)
		queue_free()

func _on_body_shape_entered(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.is_in_group("Jugador"):
		puede_Interactuar = true

func _on_body_shape_exited(_body_rid: RID, body: Node2D, _body_shape_index: int, _local_shape_index: int) -> void:
	if body.is_in_group("Jugador"):
		puede_Interactuar = false
