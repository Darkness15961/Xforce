extends CharacterBody2D

@export var velocidad: float = 100.0
@export var gravedad: float = 900.0
@export var fuerzaSalto: float = 300.0
@export var fuerzaEmpuje: float = 100.0

@onready var spriteAnimado: AnimatedSprite2D = $AnimatedSprite2D

var tiempo_sin_tocar_caja: float = 0.0

# Reproductores SFX
var sfx_salto: AudioStreamPlayer
var sfx_pisadas: AudioStreamPlayer
var sfx_caja: AudioStreamPlayer
var sfx_caida: AudioStreamPlayer

func _ready() -> void:
	if Global.deberRestaurarPosicion:
		global_position = Global.posicionJugador
		Global.deberRestaurarPosicion = false
	else:
		Global.posicionJugador = global_position
	
	_configurar_sfx()

func _configurar_sfx() -> void:
	sfx_salto = AudioStreamPlayer.new()
	sfx_salto.name = "SFXSalto"
	sfx_salto.stream = load("res://assets/audio/SFX_JUMP.mp3")
	sfx_salto.bus = &"SFX"
	add_child(sfx_salto)
	
	sfx_pisadas = AudioStreamPlayer.new()
	sfx_pisadas.name = "SFXPisadas"
	var stream_pisadas = load("res://assets/audio/SFX_PISADAS.mp3")
	if stream_pisadas is AudioStreamMP3:
		stream_pisadas.loop = true
	sfx_pisadas.stream = stream_pisadas
	sfx_pisadas.volume_db = 6.0
	sfx_pisadas.bus = &"SFX"
	add_child(sfx_pisadas)
	
	sfx_caja = AudioStreamPlayer.new()
	sfx_caja.name = "SFXCaja"
	sfx_caja.stream = load("res://assets/audio/SFX_FUNNY SHI EMPUJANDO LAS CAJAS.mp3")
	sfx_caja.volume_db = -2.0
	sfx_caja.bus = &"SFX"
	add_child(sfx_caja)
	
	sfx_caida = AudioStreamPlayer.new()
	sfx_caida.name = "SFXCaida"
	sfx_caida.stream = load("res://assets/audio/sfx_caida.mp3")
	sfx_caida.bus = &"SFX"
	sfx_caida.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(sfx_caida)

func reproducir_caida() -> void:
	if sfx_pisadas and sfx_pisadas.playing:
		sfx_pisadas.stop()
	if sfx_caja and sfx_caja.playing:
		sfx_caja.stop()
	if sfx_caida and not sfx_caida.playing:
		sfx_caida.play()

func _physics_process(delta: float) -> void:
	# Aplicación de gravedad
	if not is_on_floor():
		velocity.y += gravedad * delta
		if velocity.y > 0:
			spriteAnimado.play("fall")

	# Lógica de salto (solo un salto normal)
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = -fuerzaSalto
		spriteAnimado.play("jump")
		if sfx_salto:
			sfx_salto.play()

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

	# SFX de pisadas al correr en el suelo
	if is_on_floor() and abs(velocity.x) > 10.0:
		if sfx_pisadas and not sfx_pisadas.playing:
			sfx_pisadas.play()
	else:
		if sfx_pisadas and sfx_pisadas.playing:
			sfx_pisadas.stop()

	# Empuje de objetos RigidBody2D y SFX de contacto con cajas
	var tocando_caja: bool = false
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var objeto = colision.get_collider()
		
		if objeto is RigidBody2D:
			tocando_caja = true
			var direccionEmpuje = -colision.get_normal()
			direccionEmpuje.y = 0  # Evita empujar los objetos hacia abajo contra el suelo
			objeto.apply_central_impulse(direccionEmpuje.normalized() * fuerzaEmpuje)

	if tocando_caja:
		tiempo_sin_tocar_caja = 0.0
		if sfx_caja and not sfx_caja.playing:
			sfx_caja.play()
	else:
		tiempo_sin_tocar_caja += delta
		if tiempo_sin_tocar_caja > 0.2 and sfx_caja and sfx_caja.playing:
			sfx_caja.stop()

	# Failsafe de caída al vacío si supera el límite inferior de la pantalla
	if global_position.y > 400 and Global.EstadodoVivo:
		reproducir_caida()
		Global.deberRestaurarPosicion = true
		Global.EstadodoVivo = false
		get_tree().call_group("GameOver", "mostrar")
