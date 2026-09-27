extends Area2D

@export_file("*.tscn") var siguienteEscena: String

var jugadorActual: Node2D = null
var jugadorEnArea: bool = false

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	if not body_exited.is_connected(_on_body_exited):
		body_exited.connect(_on_body_exited)

func _process(_delta: float) -> void:
	if jugadorEnArea and Input.is_action_just_pressed("Interact"):
		cambiarEscena()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugadorEnArea = true
		jugadorActual = body

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugadorEnArea = false
		jugadorActual = null

func cambiarEscena() -> void:
	if siguienteEscena == "":
		push_warning("Transicion: 'siguienteEscena' no está configurada en el Inspector.")
		return

	if jugadorActual:
		Global.posicionJugador = jugadorActual.global_position
		Global.deberRestaurarPosicion = true

	call_deferred("_realizarCambioEscena")

func _realizarCambioEscena() -> void:
	get_tree().change_scene_to_file(siguienteEscena)
