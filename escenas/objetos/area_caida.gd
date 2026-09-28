extends Area2D

## AreaCaida.gd
## Detecta cuando el jugador cae al vacío / precipicio.
## Despliega el GameOver y asegura que al reiniciar reaparezca en su ubicación exacta guardada.

@export var retraso_game_over: float = 0.0

var _activado: bool = false

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _activado:
		return
	
	if body.is_in_group("Jugador") or body is CharacterBody2D or body.name.to_lower().contains("jugador"):
		_activado = true
		activar_game_over()

func activar_game_over() -> void:
	# Marca que el jugador debe restaurar su posición exacta guardada al recargar
	Global.deberRestaurarPosicion = true
	Global.EstadodoVivo = false
	
	if retraso_game_over > 0.0:
		await get_tree().create_timer(retraso_game_over).timeout
	
	# Despliega el GameOver de la escena
	get_tree().call_group("GameOver", "mostrar")
