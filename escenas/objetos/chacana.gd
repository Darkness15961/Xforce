extends Area2D

## Representa una de las dos mitades sagradas de la Chakana al final de cada nivel.
## Al tocarla o interactuar con ella, reproduce la animación de recolección,
## resetea la posición del jugador para el siguiente nivel y realiza la transición.

@export_file("*.tscn") var siguiente_escena: String = ""
@export var resetear_posicion_jugador: bool = true
@export var auto_recoger: bool = true
@export var animar_flotando: bool = true
@export var textura: Texture2D = null:
	set(val):
		textura = val
		if is_node_ready() and sprite:
			sprite.texture = val

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _recolectada: bool = false
var _tiempo: float = 0.0
var _pos_base_global_y: float = 0.0
var _jugador_cerca: Node2D = null

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

	if textura and sprite:
		sprite.texture = textura

	if sprite:
		_pos_base_global_y = sprite.global_position.y
		if sprite.material:
			sprite.material = sprite.material.duplicate()

	_actualizar_borde(false)

	# Failsafe si el jugador ya está dentro del área al iniciar
	for body in get_overlapping_bodies():
		if _es_jugador(body):
			_on_body_entered(body)
			break

func _process(delta: float) -> void:
	if _recolectada:
		return

	# Flotación suave en el eje Y global independiente de la rotación del nodo
	if animar_flotando and sprite:
		_tiempo += delta * 3.0
		sprite.global_position.y = _pos_base_global_y + sin(_tiempo) * 3.5

	# Permitir interacción con tecla si no se recogió automáticamente
	if _jugador_cerca and Input.is_action_just_pressed("Interact") and not Global.en_transicion:
		recolectar(_jugador_cerca)

func _es_jugador(body: Node2D) -> bool:
	return body.is_in_group("Jugador") or body is CharacterBody2D or body.name.to_lower().contains("jugador")

func _on_body_entered(body: Node2D) -> void:
	if _recolectada or not _es_jugador(body):
		return

	_jugador_cerca = body
	_actualizar_borde(true)

	if auto_recoger and not Global.en_transicion:
		recolectar(body)

func _on_body_exited(body: Node2D) -> void:
	if body == _jugador_cerca:
		_jugador_cerca = null
		if not _recolectada:
			_actualizar_borde(false)

func _actualizar_borde(activado: bool) -> void:
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("enabled", activado)

func recolectar(jugador: Node2D = null) -> void:
	if _recolectada or Global.en_transicion:
		return

	_recolectada = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	_actualizar_borde(true)

	# Congelar movimiento del jugador durante la transición de fin de nivel
	if jugador and jugador is CharacterBody2D:
		jugador.velocity = Vector2.ZERO

	# Animación de recolección mística (elevación, expansión y desvanecimiento)
	var tween = create_tween().set_parallel(true)
	if sprite:
		tween.tween_property(sprite, "scale", sprite.scale * 1.45, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
		tween.tween_property(sprite, "global_position:y", sprite.global_position.y - 20.0, 0.4)

	# Resetear posición del jugador para que el siguiente nivel inicie desde su punto de spawn oficial
	if resetear_posicion_jugador:
		Global.posicionJugador = Vector2.ZERO
		Global.deberRestaurarPosicion = false

	# Reiniciar audio para que el nuevo nivel empiece con música desde el inicio
	Global.posicionAudio = 0.0
	Global.deberRestaurarAudio = false

	if siguiente_escena != "":
		Global.cambiar_escena(siguiente_escena, 0.4, false)
	else:
		push_warning("Chacana: no se ha configurado 'siguiente_escena' en el inspector.")
