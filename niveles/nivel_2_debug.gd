extends Node2D # Este es el nodo raíz de tu nueva escena

# Pon la ruta hacia el AudioStreamPlayer de la NUEVA escena
@export var reproductorAudio: AudioStreamPlayer

func _ready() -> void:
	# Verificamos si hay un tiempo de audio guardado
	if Global.deberRestaurarAudio:
		# Reproducimos el audio desde el segundo exacto que guardamos
		reproductorAudio.play(Global.posicionAudio)
		
		# Apagamos el interruptor
		Global.deberRestaurarAudio = false
	else:
		# Si no hay nada guardado (ej. entraste a la escena directamente), se reproduce normal
		reproductorAudio.play()
