extends CharacterBody2D

@export var velocidad: float = 100.0
@export var gravedad: float = 900.0
@export var fuerzaSalto: float = 300.0
@export var maxSaltos: int = 2
@export var fuerzaEmpuje: float = 100.0

@onready var spriteAnimado: AnimatedSprite2D = $AnimatedSprite2D

var saltosRestantes: int = maxSaltos
var tiempoSinTocarCaja: float = 0.0

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
	
	sfxSalto = _crear_audio("res://assets/audio/SFX_JUMP.mp3")
	sfxPisadas = _crear_audio("res://assets/audio/SFX_PISADAS.mp3", true, 6.0)
	sfxCaja = _crear_audio("res://assets/audio/SFX_CAJAS GOLPES.mp3", false, 2.0)
	sfxCaida = _crear_audio("res://assets/audio/sfx_caida.mp3")
	sfxCaida.process_mode = Node.PROCESS_MODE_ALWAYS

func _crear_audio(ruta: String, loop: bool = false, volDb: float = 0.0) -> AudioStreamPlayer:
	var p = AudioStreamPlayer.new()
	var stream = load(ruta)
	if loop and stream is AudioStreamMP3:
		stream.loop = true
	p.stream = stream
	p.bus = &"SFX"
	p.volume_db = volDb
	add_child(p)
	return p

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

	if is_on_floor():
		saltosRestantes = maxSaltos
	else:
		velocity.y += gravedad * delta
		if velocity.y > 0:
			spriteAnimado.play("fall")

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = -fuerzaSalto
			saltosRestantes -= 1
			spriteAnimado.play("jump")
			if sfxSalto: sfxSalto.play()
		elif saltosRestantes > 0:
			velocity.y = -fuerzaSalto * 0.9
			saltosRestantes -= 1
			spriteAnimado.play("jump")
			if sfxSalto: sfxSalto.play()

	var dir = Input.get_axis("left", "right")
	if dir != 0:
		velocity.x = dir * velocidad
		spriteAnimado.flip_h = (dir < 0)
		if is_on_floor():
			spriteAnimado.play("run")
	else:
		velocity.x = 0.0
		if is_on_floor():
			spriteAnimado.play("idle")

	move_and_slide()

	if is_on_floor() and abs(velocity.x) > 10.0:
		if sfxPisadas and not sfxPisadas.playing:
			sfxPisadas.play()
	elif sfxPisadas and sfxPisadas.playing:
		sfxPisadas.stop()

	# Empuje de cajas
	var empujando = false
	for i in get_slide_collision_count():
		var col = get_slide_collision(i)
		var obj = col.get_collider()
		if obj is RigidBody2D and abs(col.get_normal().x) > 0.6:
			var dirEmpuje = -sign(col.get_normal().x)
			if dir != 0 and sign(dir) == dirEmpuje:
				empujando = true
				obj.linear_velocity.x = move_toward(obj.linear_velocity.x, dir * (velocidad * 0.65), fuerzaEmpuje * delta * 8.0)

	if empujando:
		tiempoSinTocarCaja = 0.0
		if sfxCaja and not sfxCaja.playing:
			sfxCaja.play()
	else:
		tiempoSinTocarCaja += delta
		if tiempoSinTocarCaja > 0.15 and sfxCaja and sfxCaja.playing:
			sfxCaja.stop()

	if global_position.y > 400 and Global.estadoVivo:
		reproducir_caida()
		Global.deberRestaurarPosicion = true
		Global.estadoVivo = false
		get_tree().call_group("GameOver", "mostrar")
