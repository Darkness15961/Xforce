extends CharacterBody2D

var puede_interactuar: bool = false
var Item_Usado: bool = true
@export var jugador: CharacterBody2D 
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _process(_delta: float) -> void:
	if not jugador:
		return
	anim.flip_h = jugador.global_position.x < global_position.x
	if puede_interactuar and Input.is_action_just_pressed("Interact"):
		anim.play("Distraido")
		collision_layer = 2
		if Item_Usado:
			Global.Item_Celular -= 1
			Item_Usado = false
		elif Item_Usado == false:
			pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		puede_interactuar = true
		print("Puede interactuar")

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		puede_interactuar = false
