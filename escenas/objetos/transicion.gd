extends Area2D

@export_file("*.tscn") var siguienteEscena: String
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var jugadorActual: Node2D = null
var jugadorEnArea: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if sprite and sprite.material:
		sprite.material = sprite.material.duplicate()
	_actualizar_borde(false)
	sprite.play("si")

func _process(_delta: float) -> void:
	if jugadorEnArea and Input.is_action_just_pressed("Interact") and not Global.enTransicion:
		cambiar_escena()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugadorEnArea = true
		jugadorActual = body
		_actualizar_borde(true)

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugadorEnArea = false
		jugadorActual = null
		_actualizar_borde(false)

func _actualizar_borde(activado: bool) -> void:
	if sprite and sprite.material:
		sprite.material.set_shader_parameter("enabled", activado)

func cambiar_escena() -> void:
	if siguienteEscena.is_empty():
		return
	if jugadorActual:
		Global.posicionJugador = jugadorActual.global_position
		Global.deberRestaurarPosicion = true
	Global.cambiar_escena(siguienteEscena)
