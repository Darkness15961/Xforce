extends Area2D

@export var retrasoGameOver: float = 0.0
var _activado: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _activado:
		return
	if body.is_in_group("Jugador"):
		_activado = true
		if body.has_method("reproducir_caida"):
			body.reproducir_caida()
		activar_game_over()

func activar_game_over() -> void:
	Global.deberRestaurarPosicion = true
	Global.estadoVivo = false
	if retrasoGameOver > 0.0:
		await get_tree().create_timer(retrasoGameOver).timeout
	get_tree().call_group("GameOver", "mostrar")
