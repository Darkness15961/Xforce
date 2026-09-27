extends Node2D

@export var reproductorAudio: AudioStreamPlayer

func _ready() -> void:
	if reproductorAudio:
		if Global.deberRestaurarAudio:
			# Continúa la música exactamente donde la dejaste en la escena anterior
			reproductorAudio.play(Global.posicionAudio)
			Global.deberRestaurarAudio = false
		else:
			reproductorAudio.play()

func _exit_tree() -> void:
	# El nivel guarda la posición de su propia música antes de descargarse
	if reproductorAudio and reproductorAudio.playing:
		Global.posicionAudio = reproductorAudio.get_playback_position()
		Global.deberRestaurarAudio = true
