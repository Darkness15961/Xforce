extends Node2D

var jugadorEnArea: bool = false

# Asegúrate de asignar el nodo AudioStreamPlayer en el Inspector de esta escena
@export var reproductorAudio: AudioStreamPlayer

func _ready() -> void:
	if reproductorAudio:
		if Global.deberRestaurarAudio:
			# Continúa la música exactamente donde la dejaste en la escena anterior
			reproductorAudio.play(Global.posicionAudio)
			Global.deberRestaurarAudio = false
		else:
			reproductorAudio.play()

var jugadorActual: Node2D = null

func _process(_delta: float) -> void:
	if jugadorEnArea and Input.is_action_just_pressed("Interact"):
		cambiarEscena()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugadorEnArea = true
		jugadorActual = body

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugadorEnArea = false
		jugadorActual = null

func cambiarEscena() -> void:
	if jugadorActual:
		Global.posicionJugador = jugadorActual.global_position
		Global.deberRestaurarPosicion = true

	# Guardamos el segundo exacto en el que está la canción/audio antes de salir
	if reproductorAudio:
		Global.posicionAudio = reproductorAudio.get_playback_position()
	Global.deberRestaurarAudio = true
	
	call_deferred("_realizarCambioEscena")

func _realizarCambioEscena() -> void:
	get_tree().change_scene_to_file("res://niveles/nivel1-debug.tscn")
