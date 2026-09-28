extends Control

func _ready() -> void:
	$VBoxContainer.visible = false
	if has_node("PanelCreditos"):
		$PanelCreditos.visible = false
	
	if not $AnimationPlayer.is_playing():
		# 1. Ejecuta la animación combinada (mueve a ambos personajes a la vez)
		$AnimationPlayer.play("animacion1")
		$"personaje 1/AnimatedSprite2D".play("run")
		$"personaje 2/AnimatedSprite2D".play("run")
		
		# Espera a que termine la animación conjunta
		await $AnimationPlayer.animation_finished
		if not is_inside_tree():
			return
		
		# 2. Ambos pasan a estado de descanso
		$"personaje 1/AnimatedSprite2D".play("idle")
		$"personaje 2/AnimatedSprite2D".play("idle")
		
		# Mostrar los botones una vez que comiencen a estar en idle
		$VBoxContainer.modulate.a = 0.0
		$VBoxContainer.visible = true
		var tween = create_tween()
		tween.tween_property($VBoxContainer, "modulate:a", 1.0, 0.35)
		
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
	Global.posicionAudio = 0.0
	Global.deberRestaurarAudio = false
	Global.deberRestaurarPosicion = false
	get_tree().change_scene_to_file("res://escenas/niveles/nivel2-debug.tscn")

# 2. Créditos: abre el panel de créditos
func _on_button_2_pressed() -> void:
	if has_node("PanelCreditos"):
		$PanelCreditos.visible = true

# 3. Salir: cierra el juego
func _on_button_3_pressed() -> void:
	get_tree().quit()

# Cerrar panel de créditos
func _on_btn_cerrar_creditos_pressed() -> void:
	if has_node("PanelCreditos"):
		$PanelCreditos.visible = false
