extends RigidBody2D

var sfxImpacto: AudioStreamPlayer2D = null
var tiempoUltimoImpacto: float = 0.0
var altoMitad: float = 14.0

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 8
	lock_rotation = true
	continuous_cd = RigidBody2D.CCD_MODE_CAST_RAY
	gravity_scale = 1.0
	linear_damp = 0.0

	# Material de fisica sin friccion para evitar que la caja se pegue a las paredes o flote
	var materialFisica = PhysicsMaterial.new()
	materialFisica.friction = 0.0
	materialFisica.rough = false
	materialFisica.bounce = 0.0
	physics_material_override = materialFisica

	# Correccion automatica de escala en formas de colision y calculo de altura media
	for hijo in get_children():
		if hijo is CollisionShape2D and hijo.shape:
			if hijo.scale != Vector2.ONE:
				if hijo.shape is RectangleShape2D:
					hijo.shape = hijo.shape.duplicate()
					hijo.shape.size = hijo.shape.size * hijo.scale
				elif hijo.shape is ConvexPolygonShape2D:
					hijo.shape = hijo.shape.duplicate()
					var puntosNuevos = PackedVector2Array()
					for punto in hijo.shape.points:
						puntosNuevos.append(punto * hijo.scale)
					hijo.shape.points = puntosNuevos
				hijo.scale = Vector2.ONE
			
			if hijo.shape is RectangleShape2D:
				altoMitad = max(altoMitad, hijo.shape.size.y * 0.5)
			elif hijo.shape is ConvexPolygonShape2D:
				for punto in hijo.shape.points:
					altoMitad = max(altoMitad, abs(punto.y))

	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	sfxImpacto = AudioStreamPlayer2D.new()
	sfxImpacto.name = "SFXCosasCayendo"
	sfxImpacto.stream = load("res://assets/audio/SFX_COSAS CAYENDO.mp3")
	sfxImpacto.bus = &"SFX"
	add_child(sfxImpacto)

func _physics_process(delta: float) -> void:
	tiempoUltimoImpacto += delta

func _integrate_forces(estado: PhysicsDirectBodyState2D) -> void:
	var cantidadContactos = estado.get_contact_count()
	var tocandoPared: bool = false
	var normalParedX: float = 0.0
	var tocandoSuelo: bool = false
	
	for i in range(cantidadContactos):
		var normal = estado.get_contact_local_normal(i)
		var posLocal = estado.get_contact_local_position(i)
		
		# Normal hacia arriba (normal.y < -0.6) indica contacto con el suelo
		if normal.y < -0.6:
			tocandoSuelo = true
		
		# Normal horizontal (|normal.x| > 0.6) indica contacto lateral
		if abs(normal.x) > 0.6:
			# Si el contacto esta en el borde inferior cerca del piso, se trata de una costura entre tiles de piso
			var esCosturaPiso = (posLocal.y > altoMitad - 5.0)
			if not esCosturaPiso:
				tocandoPared = true
				normalParedX = normal.x
				# Si la velocidad se dirige contra una pared real, anularla para evitar penetracion en los tiles
				if (normal.x < 0.0 and estado.linear_velocity.x > 0.0) or (normal.x > 0.0 and estado.linear_velocity.x < 0.0):
					estado.linear_velocity.x = 0.0

	# Friccion simulada solo en el suelo para detenerse suavemente cuando no la empujan
	if tocandoSuelo:
		estado.linear_velocity.x = move_toward(estado.linear_velocity.x, 0.0, 700.0 * estado.step)

	# Si esta en el aire y tocando una pared, despegarla y asegurar caida limpia sin friccion
	if tocandoPared and not tocandoSuelo:
		# Pequeña separacion hacia afuera de la pared
		estado.transform.origin.x += normalParedX * 0.4
		# Evitar que se quede suspendida en el aire contra la pared
		if estado.linear_velocity.y < 30.0 and estado.linear_velocity.y >= 0.0:
			estado.linear_velocity.y = 30.0


func _on_body_entered(_body: Node) -> void:
	if tiempoUltimoImpacto > 0.25 and abs(linear_velocity.y) > 35.0:
		tiempoUltimoImpacto = 0.0
		if sfxImpacto:
			sfxImpacto.play()
