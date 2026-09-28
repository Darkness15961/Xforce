extends Area2D

var puede_Interactuar: bool = false

func _process(delta: float) -> void:
	if puede_Interactuar and Input.is_action_just_pressed("Interact"):
		Global.Item_Celular += 1
		queue_free() # No hace falta $".", basta con llamar a queue_free()
		# Código para aumentar el valor del item en el global.

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("Jugador"):
		puede_Interactuar = true # Cambiado '==' por '='

func _on_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("Jugador"):
		puede_Interactuar = false # Cambiado '==' por '='
