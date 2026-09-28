extends Area2D

@export_file("*.tscn") var siguienteEscena: String

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var jugadorActual: Node2D = null
var jugadorEnArea: bool = false

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

	if sprite and sprite.material:
		sprite.material = sprite.material.duplicate()
	_actualizar_borde(false)
	
	# Verificar si el jugador ya se encuentra en el área al iniciar la escena
	for body in get_overlapping_bodies():
		if _es_jugador(body):
			jugadorEnArea = true
			jugadorActual = body
			_actualizar_borde(true)
			break

func _process(_delta: float) -> void:
	sprite.play("si")
	if jugadorEnArea and Input.is_action_just_pressed("Interact") and not Global.en_transicion:
		cambiarEscena()

func _es_jugador(body: Node2D) -> bool:
	return body.is_in_group("Jugador") or body is CharacterBody2D or body.name.to_lower().contains("jugador")

func _on_body_entered(body: Node2D) -> void:
	if _es_jugador(body):
		jugadorEnArea = true
		jugadorActual = body
		_actualizar_borde(true)

func _on_body_exited(body: Node2D) -> void:
	if _es_jugador(body):
		jugadorEnArea = false
		jugadorActual = null
		_actualizar_borde(false)

func _actualizar_borde(activado: bool) -> void:
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("enabled", activado)

func cambiarEscena() -> void:
	if siguienteEscena == "":
		push_warning("Transicion: 'siguienteEscena' no está configurada en el Inspector.")
		return

	if jugadorActual:
		Global.posicionJugador = jugadorActual.global_position
		Global.deberRestaurarPosicion = true

	# Guardar la posición exacta del audio en este instante preciso
	var escena_actual = get_tree().current_scene
	if escena_actual:
		var audio = escena_actual.get_node_or_null("AudioStreamPlayer")
		if audio and audio is AudioStreamPlayer and audio.playing:
			Global.posicionAudio = audio.get_playback_position()
			Global.deberRestaurarAudio = true

	call_deferred("_realizarCambioEscena")

func _realizarCambioEscena() -> void:
	Global.cambiar_escena(siguienteEscena)
