extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not $AnimationPlayer.is_playing():
		# 1. Ejecuta la animación combinada (mueve a ambos personajes a la vez)
		$AnimationPlayer.play("animacion1")
		$"personaje 1/AnimatedSprite2D".play("run")
		$"personaje 2/AnimatedSprite2D".play("run")
		
		# Espera a que termine la animación conjunta
		await $AnimationPlayer.animation_finished
		
		# 2. Ambos pasan a estado de descanso
		$"personaje 1/AnimatedSprite2D".play("idle")
		$"personaje 2/AnimatedSprite2D".play("idle")
		
		# Tiempo de espera aleatorio entre 5 y 15 segundos
		var tiempo_espera = randf_range(5.0, 15.0)
		await get_tree().create_timer(tiempo_espera).timeout
		
		# 3. Voltea los personajes y ejecuta la segunda animación combinada
		$"personaje 1/AnimatedSprite2D".flip_h = false
		$"personaje 2/AnimatedSprite2D".flip_h = true
		
		$AnimationPlayer.play("animacion2")
		$"personaje 1/AnimatedSprite2D".play("run")
		$"personaje 2/AnimatedSprite2D".play("run")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
