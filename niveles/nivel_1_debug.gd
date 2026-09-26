extends Node2D

var jugadorEnArea: bool = false

# Asegúrate de poner la ruta correcta hacia tu nodo AudioStreamPlayer en esta escena
@export var reproductorAudio: AudioStreamPlayer

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	if jugadorEnArea and Input.is_action_just_pressed("Interact"):
		cambiarEscena()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugadorEnArea = true
		Global.posicionJugador = body.global_position
		Global.deberRestaurarPosicion = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		jugadorEnArea = false

func cambiarEscena() -> void:
	# Guardamos el segundo exacto en el que está la canción/audio
	Global.posicionAudio = reproductorAudio.get_playback_position()
	Global.deberRestaurarAudio = true
	
	call_deferred("_realizarCambioEscena")

func _realizarCambioEscena() -> void:
	get_tree().change_scene_to_file("res://niveles/nivel2-debug.tscn")
