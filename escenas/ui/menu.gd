extends Control

func _ready() -> void:
	Global.reproducir_musica_menu()
	
	if Global.animacion_inicial_menu_vista:
		# Si ya se vio la animación inicial, colocar a los personajes directamente en reposo
		$"personaje 1".position = Vector2(382, 286)
		$"personaje 2".position = Vector2(260, 284)
		$"personaje 1/AnimatedSprite2D".flip_h = true
		$"personaje 2/AnimatedSprite2D".flip_h = false
		$"personaje 1/AnimatedSprite2D".play("idle")
		$"personaje 2/AnimatedSprite2D".play("idle")
		
		# Mostrar los botones de inmediato listos para interactuar
		$VBoxContainer.modulate.a = 1.0
		$VBoxContainer.visible = true
		$VBoxContainer/Button.grab_focus()
		
		_iniciar_espera_animacion2()
	else:
		# Primera vez al abrir el juego: ocultar botones y reproducir la animación inicial
		$VBoxContainer.visible = false
		
		if not $AnimationPlayer.is_playing():
			# 1. Ejecuta la animación combinada (mueve a ambos personajes a la vez)
			$AnimationPlayer.play("animacion1")
			$"personaje 1/AnimatedSprite2D".play("run")
			$"personaje 2/AnimatedSprite2D".play("run")
			
			# Espera a que termine la animación conjunta
			await $AnimationPlayer.animation_finished
			if not is_inside_tree():
				return
			
			# Marcar que la animación inicial ya se completó por primera vez
			Global.animacion_inicial_menu_vista = true
			
			# 2. Ambos pasan a estado de descanso
			$"personaje 1/AnimatedSprite2D".play("idle")
			$"personaje 2/AnimatedSprite2D".play("idle")
			
			# Mostrar los botones una vez que comiencen a estar en idle
			$VBoxContainer.modulate.a = 0.0
			$VBoxContainer.visible = true
			$VBoxContainer/Button.grab_focus()
			var tween = create_tween()
			tween.tween_property($VBoxContainer, "modulate:a", 1.0, 0.35)
			
			_iniciar_espera_animacion2()

func _iniciar_espera_animacion2() -> void:
	# Tiempo de espera aleatorio entre 5 y 15 segundos
	var tiempo_espera = randf_range(5.0, 15.0)
	await get_tree().create_timer(tiempo_espera).timeout
	if not is_inside_tree():
		return
	
	# 3. Voltea los personajes y ejecuta la segunda animación combinada
	$"personaje 1/AnimatedSprite2D".flip_h = false
	$"personaje 2/AnimatedSprite2D".flip_h = true
	
	$AnimationPlayer.play("animacion2")
	$"personaje 1/AnimatedSprite2D".play("run")
	$"personaje 2/AnimatedSprite2D".play("run")

func _process(_delta: float) -> void:
	pass

# 1. Jugar: lleva al nivel 2
func _on_button_pressed() -> void:
	Global.animacion_inicial_menu_vista = true
	Global.posicionAudio = 0.0
	Global.deberRestaurarAudio = false
	Global.deberRestaurarPosicion = false
	Global.cambiar_escena("res://escenas/niveles/nivel2-debug.tscn")

# 2. Créditos: cambia a la escena de créditos independiente
func _on_button_2_pressed() -> void:
	Global.animacion_inicial_menu_vista = true
	Global.cambiar_escena("res://escenas/ui/Creditos.tscn")

# 3. Salir: cierra el juego
func _on_button_3_pressed() -> void:
	get_tree().quit()
