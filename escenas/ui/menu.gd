extends Control

@onready var p1: Node2D = $"personaje 1"
@onready var p2: Node2D = $"personaje 2"
@onready var animP1: AnimatedSprite2D = $"personaje 1/AnimatedSprite2D"
@onready var animP2: AnimatedSprite2D = $"personaje 2/AnimatedSprite2D"
@onready var animPlayer: AnimationPlayer = $AnimationPlayer
@onready var contenedorBotones: VBoxContainer = $VBoxContainer
@onready var btnJugar: Button = $VBoxContainer/Button

func _ready() -> void:
	Global.reproducir_musica_menu()
	
	if Global.animacionInicialMenuVista:
		p1.position = Vector2(382, 286)
		p2.position = Vector2(260, 284)
		animP1.flip_h = true
		animP2.flip_h = false
		animP1.play("idle")
		animP2.play("idle")
		contenedorBotones.visible = true
		btnJugar.grab_focus()
		_iniciar_espera_animacion2()
	else:
		contenedorBotones.visible = false
		animPlayer.play("animacion1")
		animP1.play("run")
		animP2.play("run")
		await animPlayer.animation_finished
		if not is_inside_tree():
			return
		
		Global.animacionInicialMenuVista = true
		animP1.play("idle")
		animP2.play("idle")
		contenedorBotones.modulate.a = 0.0
		contenedorBotones.visible = true
		btnJugar.grab_focus()
		create_tween().tween_property(contenedorBotones, "modulate:a", 1.0, 0.35)
		_iniciar_espera_animacion2()

func _iniciar_espera_animacion2() -> void:
	await get_tree().create_timer(randf_range(5.0, 15.0)).timeout
	if not is_inside_tree():
		return
	animP1.flip_h = false
	animP2.flip_h = true
	animPlayer.play("animacion2")
	animP1.play("run")
	animP2.play("run")

func _on_button_pressed() -> void:
	Global.animacionInicialMenuVista = true
	Global.posicionAudio = 0.0
	Global.deberRestaurarAudio = false
	Global.deberRestaurarPosicion = false
	Global.cambiar_escena("res://escenas/Intro/Intro.tscn")

func _on_button_2_pressed() -> void:
	Global.animacionInicialMenuVista = true
	Global.cambiar_escena("res://escenas/ui/Creditos.tscn")

func _on_button_3_pressed() -> void:
	get_tree().quit()
