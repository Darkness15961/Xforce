extends Area2D

@export var retrasoGameOver: float = 0.0
var _activado: bool = false
var sfxCaida: AudioStreamPlayer = null

func _ready() -> void:
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
	if body.is_in_group("Jugador"):
		_activado = true
		if body.has_method("reproducir_caida"):
			body.reproducir_caida()
		elif sfxCaida and not sfxCaida.playing:
			sfxCaida.play()
		activar_game_over()

func activar_game_over() -> void:
	Global.deberRestaurarPosicion = true
	Global.estadoVivo = false
	if retrasoGameOver > 0.0:
		await get_tree().create_timer(retrasoGameOver).timeout
	get_tree().call_group("GameOver", "mostrar")
