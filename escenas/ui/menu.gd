extends Control

func _ready() -> void:
	Global.reproducir_musica_menu()
	
	if Global.animacionInicialMenuVista:
		# Si ya se vio la animacion inicial, colocar a los personajes directamente en reposo
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
		# Primera vez al abrir el juego: ocultar botones y reproducir la animacion inicial
		$VBoxContainer.visible = false
		
		if not $AnimationPlayer.is_playing():
			# 1. Ejecuta la animacion combinada (mueve a ambos personajes a la vez)
			$AnimationPlayer.play("animacion1")
			$"personaje 1/AnimatedSprite2D".play("run")
			$"personaje 2/AnimatedSprite2D".play("run")
			
			# Espera a que termine la animacion conjunta
			await $AnimationPlayer.animation_finished
			if not is_inside_tree():
				return
			
			# Marcar que la animacion inicial ya se completo por primera vez
			Global.animacionInicialMenuVista = true
			
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
	var tiempoEspera = randf_range(5.0, 15.0)
	await get_tree().create_timer(tiempoEspera).timeout
	if not is_inside_tree():
		return
	
	# 3. Voltea los personajes y ejecuta la segunda animacion combinada
	$"personaje 1/AnimatedSprite2D".flip_h = false
	$"personaje 2/AnimatedSprite2D".flip_h = true
	
	$AnimationPlayer.play("animacion2")
	$"personaje 1/AnimatedSprite2D".play("run")
	$"personaje 2/AnimatedSprite2D".play("run")

func _process(_delta: float) -> void:
	pass

# 1. Jugar: lleva al nivel 2
func _on_button_pressed() -> void:
	Global.animacionInicialMenuVista = true
	Global.posicionAudio = 0.0
	Global.deberRestaurarAudio = false
	Global.deberRestaurarPosicion = false
	Global.cambiar_escena("res://escenas/Intro/Intro.tscn")

# 2. Creditos: cambia a la escena de creditos independiente
func _on_button_2_pressed() -> void:
	Global.animacionInicialMenuVista = true
	Global.cambiar_escena("res://escenas/ui/Creditos.tscn")

# 3. Salir: cierra el juego
func _on_button_3_pressed() -> void:
	get_tree().quit()
