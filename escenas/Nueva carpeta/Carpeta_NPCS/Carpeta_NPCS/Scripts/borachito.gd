extends CharacterBody2D

var puede_interactuar: bool = false

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D


func _process(_delta: float) -> void:
	if puede_interactuar and Input.is_action_just_pressed("Interact"):
		anim.play("Distraido")
		collision_layer = 2
		#Codigo para restar 1 al valor del item

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("Jugador") or area.get_parent().is_in_group("Jugador"):
		puede_interactuar = true

func _on_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("Jugador") or area.get_parent().is_in_group("Jugador"):
		puede_interactuar = false
