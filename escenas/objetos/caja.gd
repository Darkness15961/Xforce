extends RigidBody2D

var sfx_impacto: AudioStreamPlayer2D = null
var tiempo_ultimo_impacto: float = 0.0

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	lock_rotation = true
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	gravity_scale = 1.0
	linear_damp = 0.0

	# Material de física sin fricción para evitar que la caja se pegue a las paredes o flote
	var mat = PhysicsMaterial.new()
	mat.friction = 0.0
	mat.rough = false
	mat.bounce = 0.0
	physics_material_override = mat

	# Corrección automática de escala en formas de colisión para evitar enganches con bordes de tiles
	for child in get_children():
		if child is CollisionShape2D and child.shape:
			if child.scale != Vector2.ONE:
				if child.shape is RectangleShape2D:
					child.shape = child.shape.duplicate()
					child.shape.size = child.shape.size * child.scale
				child.scale = Vector2.ONE

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	sfx_impacto = AudioStreamPlayer2D.new()
	sfx_impacto.name = "SFXCosasCayendo"
	sfx_impacto.stream = load("res://assets/audio/SFX_COSAS CAYENDO.mp3")
	sfx_impacto.bus = &"SFX"
	add_child(sfx_impacto)

func _physics_process(delta: float) -> void:
	tiempo_ultimo_impacto += delta

func _integrate_forces(state: PhysicsDirectBodyState2D) -> void:
	var contact_count = state.get_contact_count()
	var tocando_pared: bool = false
	var normal_pared_x: float = 0.0
	var tocando_suelo: bool = false
	
	for i in range(contact_count):
		var normal = state.get_contact_local_normal(i)
		# Normal hacia arriba (normal.y < -0.6) indica contacto con el suelo
		if normal.y < -0.6:
			tocando_suelo = true
		# Normal horizontal (|normal.x| > 0.6) indica contacto con pared u obstáculo vertical
		if abs(normal.x) > 0.6:
			tocando_pared = true
			normal_pared_x = normal.x
			# Si la velocidad se dirige contra la pared, anularla para evitar penetración en los tiles
			if (normal.x < 0.0 and state.linear_velocity.x > 0.0) or (normal.x > 0.0 and state.linear_velocity.x < 0.0):
				state.linear_velocity.x = 0.0

	# Fricción simulada solo en el suelo para detenerse suavemente cuando no la empujan
	if tocando_suelo:
		state.linear_velocity.x = move_toward(state.linear_velocity.x, 0.0, 700.0 * state.step)

	# Si está en el aire y tocando una pared, despegarla y asegurar caída limpia sin fricción
	if tocando_pared and not tocando_suelo:
		# Pequeña separación hacia afuera de la pared
		state.transform.origin.x += normal_pared_x * 0.4
		# Evitar que se quede suspendida en el aire contra la pared
		if state.linear_velocity.y < 30.0 and state.linear_velocity.y >= 0.0:
			state.linear_velocity.y = 30.0

func _on_body_entered(_body: Node) -> void:
	if tiempo_ultimo_impacto > 0.25 and abs(linear_velocity.y) > 35.0:
		tiempo_ultimo_impacto = 0.0
		if sfx_impacto:
			sfx_impacto.play()
