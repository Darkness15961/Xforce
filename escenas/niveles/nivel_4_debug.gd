extends Node2D

@onready var reproductorAudio: AudioStreamPlayer = get_node_or_null("AudioStreamPlayer")

func _ready() -> void:
	Global.detener_musica_menu()
	if reproductorAudio:
		var pos = Global.posicionAudio
		if pos > 0.0 and reproductorAudio.stream and reproductorAudio.stream.get_length() > 0.0:
			pos = fmod(pos, reproductorAudio.stream.get_length())
		reproductorAudio.play(pos)

func _process(_delta: float) -> void:
	if reproductorAudio and reproductorAudio.playing:
		Global.posicionAudio = reproductorAudio.get_playback_position()
