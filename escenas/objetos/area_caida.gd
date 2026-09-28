extends Area2D

## AreaCaida.gd
## Detecta cuando el jugador cae al vacio / precipicio.
## Despliega el GameOver y asegura que al reiniciar reaparezca en su ubicacion exacta guardada.

@export var retrasoGameOver: float = 0.0

#region Alias de compatibilidad
var retraso_game_over: float:
	get: return retrasoGameOver
	set(val): retrasoGameOver = val
#endregion

var _activado: bool = false
var sfxCaida: AudioStreamPlayer = null

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	sfxCaida = AudioStreamPlayer.new()
	sfxCaida.name = "SFXCaida"
	sfxCaida.stream = load("res://assets/audio/sfx_caida.mp3")
	sfxCaida.bus = &"SFX"
	sfxCaida.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(sfxCaida)

func _on_body_entered(body: Node2D) -> void:
	if _activado:
		return
	
	if body.is_in_group("Jugador") or body is CharacterBody2D or body.name.to_lower().contains("jugador"):
		_activado = true
		if body.has_method("reproducir_caida"):
			body.reproducir_caida()
		elif sfxCaida and not sfxCaida.playing:
			sfxCaida.play()
		activar_game_over()

func activar_game_over() -> void:
	# Marca que el jugador debe restaurar su posicion exacta guardada al recargar
	Global.deberRestaurarPosicion = true
	Global.estadoVivo = false
	
	if retrasoGameOver > 0.0:
		await get_tree().create_timer(retrasoGameOver).timeout
	
	# Despliega el GameOver de la escena
	get_tree().call_group("GameOver", "mostrar")
