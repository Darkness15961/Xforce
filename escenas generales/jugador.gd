extends CharacterBody2D

@export var velocidad: float = 100.0
@export var gravedad: float = 900.0
@export var fuerzaSalto: float = 300.0
@export var maxSaltos: int = 2
@export var fuerzaEmpuje: float = 100.0

@onready var spriteAnimado: AnimatedSprite2D = $AnimatedSprite2D

var saltosRestantes: int = maxSaltos
func _ready() -> void:
	if Global.deberRestaurarPosicion:
		global_position = Global.posicionJugador
		Global.deberRestaurarPosicion = false
func _physics_process(delta: float) -> void:
	# Aplicación de gravedad y reinicio de saltos
	if is_on_floor():
		saltosRestantes = maxSaltos
	else:
		velocity.y += gravedad * delta
		if velocity.y > 0:
			spriteAnimado.play("fall")

	# Lógica de salto (suelo y doble salto)
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -fuerzaSalto
			saltosRestantes -= 1
			spriteAnimado.play("jump")
		elif saltosRestantes > 0:
			velocity.y = -fuerzaSalto * 0.9
			saltosRestantes -= 1
			spriteAnimado.play("jump")

	# Movimiento horizontal y dirección del sprite
	var direccionHorizontal = Input.get_axis("left", "right")
	if direccionHorizontal != 0:
		velocity.x = direccionHorizontal * velocidad
		spriteAnimado.flip_h = (direccionHorizontal < 0)
		if is_on_floor():
			spriteAnimado.play("run")
	else:
		velocity.x = 0.0
		if is_on_floor():
			spriteAnimado.play("idle")

	move_and_slide()

	# Empuje de objetos RigidBody2D
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var objeto = colision.get_collider()
		
		if objeto is RigidBody2D:
			var direccionEmpuje = -colision.get_normal()
			direccionEmpuje.y = 0  # Evita empujar los objetos hacia abajo contra el suelo
			objeto.apply_central_impulse(direccionEmpuje.normalized() * fuerzaEmpuje)
