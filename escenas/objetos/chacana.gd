extends Area2D

## Representa una de las dos mitades sagradas de la Chakana al final de cada nivel.
## Al tocarla o interactuar con ella, reproduce la animacion de recoleccion,
## resetea la posicion del jugador para el siguiente nivel y realiza la transicion.

@export_file("*.tscn") var siguienteEscena: String = ""
@export var resetearPosicionJugador: bool = true
@export var autoRecoger: bool = true
@export var animarFlotando: bool = true
@export var textura: Texture2D = null:
	set(val):
		textura = val
		if is_node_ready() and sprite:
			sprite.texture = val

#region Alias de compatibilidad
var siguiente_escena: String:
	get: return siguienteEscena
	set(val): siguienteEscena = val

var resetear_posicion_jugador: bool:
	get: return resetearPosicionJugador
	set(val): resetearPosicionJugador = val

var auto_recoger: bool:
	get: return autoRecoger
	set(val): autoRecoger = val

var animar_flotando: bool:
	get: return animarFlotando
	set(val): animarFlotando = val
#endregion

@onready var sprite: Sprite2D = $Sprite2D
@onready var formaColision: CollisionShape2D = $CollisionShape2D

var _recolectada: bool = false
var _tiempo: float = 0.0
var _posBaseGlobalY: float = 0.0
var _jugadorCerca: Node2D = null

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

	if textura and sprite:
		sprite.texture = textura

	if sprite:
		_posBaseGlobalY = sprite.global_position.y
		if sprite.material:
			sprite.material = sprite.material.duplicate()

	_actualizar_borde(false)

	# Failsafe si el jugador ya esta dentro del area al iniciar
	for body in get_overlapping_bodies():
		if _es_jugador(body):
			_on_body_entered(body)
			break

func _process(delta: float) -> void:
	if _recolectada:
		return

	# Flotacion suave en el eje Y global independiente de la rotacion del nodo
	if animarFlotando and sprite:
		_tiempo += delta * 3.0
		sprite.global_position.y = _posBaseGlobalY + sin(_tiempo) * 3.5

	# Permitir interaccion con tecla si no se recogio automaticamente
	if _jugadorCerca and Input.is_action_just_pressed("Interact") and not Global.enTransicion:
		recolectar(_jugadorCerca)

func _es_jugador(body: Node2D) -> bool:
	return body.is_in_group("Jugador") or body is CharacterBody2D or body.name.to_lower().contains("jugador")

func _on_body_entered(body: Node2D) -> void:
	if _recolectada or not _es_jugador(body):
		return

	_jugadorCerca = body
	_actualizar_borde(true)

	if autoRecoger and not Global.enTransicion:
		recolectar(body)

func _on_body_exited(body: Node2D) -> void:
	if body == _jugadorCerca:
		_jugadorCerca = null
		if not _recolectada:
			_actualizar_borde(false)

func _actualizar_borde(activado: bool) -> void:
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("enabled", activado)

func recolectar(jugador: Node2D = null) -> void:
	if _recolectada or Global.enTransicion:
		return

	_recolectada = true
	set_deferred("monitoring", false)
	set_deferred("monitorable", false)
	_actualizar_borde(true)

	# Congelar movimiento del jugador durante la transicion de fin de nivel
	if jugador and jugador is CharacterBody2D:
		jugador.velocity = Vector2.ZERO

	# Animacion de recoleccion mistica (elevacion, expansion y desvanecimiento)
	var tween = create_tween().set_parallel(true)
	if sprite:
		tween.tween_property(sprite, "scale", sprite.scale * 1.45, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
		tween.tween_property(sprite, "global_position:y", sprite.global_position.y - 20.0, 0.4)

	# Resetear posicion del jugador para que el siguiente nivel inicie desde su punto de spawn oficial
	if resetearPosicionJugador:
		Global.posicionJugador = Vector2.ZERO
		Global.deberRestaurarPosicion = false

	# Reiniciar audio para que el nuevo nivel empiece con musica desde el inicio
	Global.posicionAudio = 0.0
	Global.deberRestaurarAudio = false

	if siguienteEscena != "":
		Global.cambiar_escena(siguienteEscena, 0.4, false)
	else:
		push_warning("Chacana: no se ha configurado 'siguienteEscena' en el inspector.")
