extends Area2D

@export_file("*.tscn") var siguienteEscena: String = ""
@export var resetearPosicionJugador: bool = true
@export var autoRecoger: bool = true
@export var animarFlotando: bool = true
@export var textura: Texture2D = null:
	set(val):
		textura = val
		if is_node_ready() and sprite:
			sprite.texture = val

@onready var sprite: Sprite2D = $Sprite2D

var _recolectada: bool = false
var _tiempo: float = 0.0
var _posBaseGlobalY: float = 0.0
var _jugadorCerca: Node2D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if textura and sprite:
		sprite.texture = textura
	if sprite:
		_posBaseGlobalY = sprite.global_position.y
		if sprite.material:
			sprite.material = sprite.material.duplicate()
	_actualizar_borde(false)

func _process(delta: float) -> void:
	if _recolectada:
		return
	if animarFlotando and sprite:
		_tiempo += delta * 3.0
		sprite.global_position.y = _posBaseGlobalY + sin(_tiempo) * 3.5
	if _jugadorCerca and Input.is_action_just_pressed("Interact") and not Global.enTransicion:
		recolectar(_jugadorCerca)

func _on_body_entered(body: Node2D) -> void:
	if _recolectada or not body.is_in_group("Jugador"):
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

	if jugador and jugador is CharacterBody2D:
		jugador.velocity = Vector2.ZERO

	var tween = create_tween().set_parallel(true)
	if sprite:
		tween.tween_property(sprite, "scale", sprite.scale * 1.45, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
		tween.tween_property(sprite, "global_position:y", sprite.global_position.y - 20.0, 0.4)

	if resetearPosicionJugador:
		Global.posicionJugador = Vector2.ZERO
		Global.deberRestaurarPosicion = false

	Global.posicionAudio = 0.0
	Global.deberRestaurarAudio = false

	if not siguienteEscena.is_empty():
		Global.cambiar_escena(siguienteEscena, 0.4, false)
