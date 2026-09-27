extends Node2D

@export var reproductorAudio: AudioStreamPlayer

func _ready() -> void:
	if reproductorAudio:
		if Global.deberRestaurarAudio:
			# Reproduce desde el segundo guardado
			reproductorAudio.play(Global.posicionAudio)
			Global.deberRestaurarAudio = false
		else:
			# Si es la primera vez que entras al juego, reproduce desde el inicio
			reproductorAudio.play()

func _exit_tree() -> void:
	# El nivel guarda la posición de su propia música antes de descargarse
	if reproductorAudio and reproductorAudio.playing:
		Global.posicionAudio = reproductorAudio.get_playback_position()
		Global.deberRestaurarAudio = true
