extends Node2D

@export var reproductorAudio: AudioStreamPlayer

func _ready() -> void:
	Global.detener_musica_menu()
	if not reproductorAudio:
		reproductorAudio = get_node_or_null("AudioStreamPlayer")
		
	if reproductorAudio:
		if Global.posicionAudio > 0.0:
			var duracion: float = reproductorAudio.stream.get_length() if reproductorAudio.stream else 0.0
			var posInicio: float = Global.posicionAudio
			if duracion > 0.0 and posInicio >= duracion:
				posInicio = fmod(posInicio, duracion)
			reproductorAudio.play(posInicio)
		else:
			reproductorAudio.play()

func _process(_delta: float) -> void:
	# Mantiene actualizada en todo momento la posicion exacta de reproduccion
	if reproductorAudio and reproductorAudio.playing:
		Global.posicionAudio = reproductorAudio.get_playback_position()

func _exit_tree() -> void:
	# Respaldo antes de descargar la escena
	if reproductorAudio and reproductorAudio.playing:
		Global.posicionAudio = reproductorAudio.get_playback_position()
