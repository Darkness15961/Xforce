extends CharacterBody2D

@export var velocidad: float = 100.0
@export var gravedad: float = 900.0
@export var fuerzaSalto: float = 300.0
@export var maxSaltos: int = 2
@export var fuerzaEmpuje: float = 100.0

@onready var spriteAnimado: AnimatedSprite2D = $AnimatedSprite2D

var saltosRestantes: int = maxSaltos
var tiempoSinTocarCaja: float = 0.0

# Reproductores SFX
var sfxSalto: AudioStreamPlayer
var sfxPisadas: AudioStreamPlayer
var sfxCaja: AudioStreamPlayer
var sfxCaida: AudioStreamPlayer

func _ready() -> void:
	add_to_group("Jugador")
	if Global.deberRestaurarPosicion:
		global_position = Global.posicionJugador
		Global.deberRestaurarPosicion = false
	else:
		Global.posicionJugador = global_position
	
	_configurar_sfx()

func _configurar_sfx() -> void:
	sfxSalto = AudioStreamPlayer.new()
	sfxSalto.name = "SFXSalto"
	sfxSalto.stream = load("res://assets/audio/SFX_JUMP.mp3")
	sfxSalto.bus = &"SFX"
	add_child(sfxSalto)
	
	sfxPisadas = AudioStreamPlayer.new()
	sfxPisadas.name = "SFXPisadas"
	var flujoPisadas = load("res://assets/audio/SFX_PISADAS.mp3")
	if flujoPisadas is AudioStreamMP3:
		flujoPisadas.loop = true
	sfxPisadas.stream = flujoPisadas
	sfxPisadas.volume_db = 6.0
	sfxPisadas.bus = &"SFX"
	add_child(sfxPisadas)
	
	sfxCaja = AudioStreamPlayer.new()
	sfxCaja.name = "SFXCaja"
	sfxCaja.stream = load("res://assets/audio/SFX_CAJAS GOLPES.mp3")
	sfxCaja.volume_db = 2.0
	sfxCaja.bus = &"SFX"
	add_child(sfxCaja)
	
	sfxCaida = AudioStreamPlayer.new()
	sfxCaida.name = "SFXCaida"
	sfxCaida.stream = load("res://assets/audio/sfx_caida.mp3")
	sfxCaida.bus = &"SFX"
	sfxCaida.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(sfxCaida)

func reproducir_caida() -> void:
	if sfxPisadas and sfxPisadas.playing:
		sfxPisadas.stop()
	if sfxCaja and sfxCaja.playing:
		sfxCaja.stop()
	if sfxCaida and not sfxCaida.playing:
		sfxCaida.play()

func _physics_process(delta: float) -> void:
	if Global.enDialogo:
		velocity.x = 0.0
		if not is_on_floor():
			velocity.y += gravedad * delta
		else:
			velocity.y = 0.0
			spriteAnimado.play("idle")
		if sfxPisadas and sfxPisadas.playing:
			sfxPisadas.stop()
		move_and_slide()
		return

	# Aplicacion de gravedad y reinicio de saltos
	if is_on_floor():
		saltosRestantes = maxSaltos
	else:
		velocity.y += gravedad * delta
		if velocity.y > 0:
			spriteAnimado.play("fall")

	# Logica de salto (suelo y doble salto)
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -fuerzaSalto
			saltosRestantes -= 1
			spriteAnimado.play("jump")
			if sfxSalto:
				sfxSalto.play()
		elif saltosRestantes > 0:
			velocity.y = -fuerzaSalto * 0.9
			saltosRestantes -= 1
			spriteAnimado.play("jump")
			if sfxSalto:
				sfxSalto.play()

	# Movimiento horizontal y direccion del sprite
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
		if sfxPisadas and not sfxPisadas.playing:
			sfxPisadas.play()
	else:
		if sfxPisadas and sfxPisadas.playing:
			sfxPisadas.stop()

	# Empuje de objetos RigidBody2D y SFX de contacto con cajas
	var empujandoCaja: bool = false
	for i in get_slide_collision_count():
		var colision = get_slide_collision(i)
		var objeto = colision.get_collider()
		
		if objeto is RigidBody2D:
			var normal = colision.get_normal()
			# Solo empujar si el contacto es lateral y el jugador camina hacia la caja
			if abs(normal.x) > 0.6:
				var direccionEmpuje = -sign(normal.x)
				if direccionHorizontal != 0 and sign(direccionHorizontal) == direccionEmpuje:
					empujandoCaja = true
					var velocidadObjetivo = direccionHorizontal * (velocidad * 0.65)
					objeto.linear_velocity.x = move_toward(objeto.linear_velocity.x, velocidadObjetivo, fuerzaEmpuje * delta * 8.0)

	if empujandoCaja:
		tiempoSinTocarCaja = 0.0
		if sfxCaja and not sfxCaja.playing:
			sfxCaja.play()
	else:
		tiempoSinTocarCaja += delta
		if tiempoSinTocarCaja > 0.15 and sfxCaja and sfxCaja.playing:
			sfxCaja.stop()

	# Failsafe de caida al vacio si supera el limite inferior de la pantalla
	if global_position.y > 400 and Global.estadoVivo:
		reproducir_caida()
		Global.deberRestaurarPosicion = true
		Global.estadoVivo = false
		get_tree().call_group("GameOver", "mostrar")
