extends Node2D

@export var reproductorAudio: AudioStreamPlayer

func _ready() -> void:
	Global.detener_musica_menu()
	if not reproductorAudio:
		reproductorAudio = get_node_or_null("AudioStreamPlayer")
		
	if reproductorAudio:
		if Global.posicionAudio > 0.0:
			var duracion: float = reproductorAudio.stream.get_length() if reproductorAudio.stream else 0.0
			var pos_inicio: float = Global.posicionAudio
			if duracion > 0.0 and pos_inicio >= duracion:
				pos_inicio = fmod(pos_inicio, duracion)
			reproductorAudio.play(pos_inicio)
		else:
			reproductorAudio.play()

func _process(_delta: float) -> void:
	# Mantiene actualizada en todo momento la posición exacta de reproducción
	if reproductorAudio and reproductorAudio.playing:
		Global.posicionAudio = reproductorAudio.get_playback_position()

func _exit_tree() -> void:
	# Respaldo antes de descargar la escena
	if reproductorAudio and reproductorAudio.playing:
		Global.posicionAudio = reproductorAudio.get_playback_position()
