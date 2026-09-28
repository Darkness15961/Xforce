extends Area2D

var puede_Interactuar: bool = false

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	if puede_Interactuar and Input.is_action_just_pressed("Interactuar"):
		$".".queue_free()
		#codigo para aumentar el valor del item en el global.
	pass

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Jugador"):
		puede_Interactuar == true
	pass # Replace with function body.


func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Jugador"):
		puede_Interactuar == false
	pass # Replace with function body.
