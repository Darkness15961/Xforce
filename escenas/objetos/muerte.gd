extends Area2D

@export var retrasoGameOver: float = 0.0

#region Alias de compatibilidad
var retraso_game_over: float:
	get: return retrasoGameOver
	set(val): retrasoGameOver = val
#endregion

var _activado: bool = false

func _ready() -> void:
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _activado:
		return
	
	if body.is_in_group("Jugador") or body is CharacterBody2D or body.name.to_lower().contains("jugador"):
		_activado = true
		if body.has_method("reproducir_caida"):
			body.reproducir_caida()
		activar_game_over()

func activar_game_over() -> void:
	# Marca que el jugador debe restaurar su posicion exacta guardada al recargar
	Global.deberRestaurarPosicion = true
	Global.estadoVivo = false
	
	if retrasoGameOver > 0.0:
		await get_tree().create_timer(retrasoGameOver).timeout
	
	# Despliega el GameOver de la escena
	get_tree().call_group("GameOver", "mostrar")
