extends Area2D

## AreaCaida.gd
## Detecta cuando el jugador cae al vacío / precipicio.
## Despliega el GameOver y asegura que al reiniciar reaparezca en su ubicación exacta guardada.

@export var retraso_game_over: float = 0.0

var _activado: bool = false
var sfx_caida: AudioStreamPlayer = null

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	sfx_caida = AudioStreamPlayer.new()
	sfx_caida.name = "SFXCaida"
	sfx_caida.stream = load("res://assets/audio/sfx_caida.mp3")
	sfx_caida.bus = &"SFX"
	sfx_caida.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(sfx_caida)

func _on_body_entered(body: Node2D) -> void:
	if _activado:
		return
	
	if body.is_in_group("Jugador") or body is CharacterBody2D or body.name.to_lower().contains("jugador"):
		_activado = true
		if body.has_method("reproducir_caida"):
			body.reproducir_caida()
		elif sfx_caida and not sfx_caida.playing:
			sfx_caida.play()
		activar_game_over()

func activar_game_over() -> void:
	# Marca que el jugador debe restaurar su posición exacta guardada al recargar
	Global.deberRestaurarPosicion = true
	Global.EstadodoVivo = false
	
	if retraso_game_over > 0.0:
		await get_tree().create_timer(retraso_game_over).timeout
	
	# Despliega el GameOver de la escena
	get_tree().call_group("GameOver", "mostrar")
