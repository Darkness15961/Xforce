extends CanvasLayer

@export_file("*.tscn") var ReinicioEscena: String
@export var ocultar: Control

var sfx_game_over: AudioStreamPlayer = null

func _ready() -> void:
	add_to_group("GameOver")
	visible = false
	if has_node("ColorRect"):
		$ColorRect.visible = false
	if has_node("VBoxContainer"):
		$VBoxContainer.visible = false
	Global.EstadodoVivo = true
	Global.bloquear_pausa = false
	Global.gameoveractivo = false
	
	sfx_game_over = AudioStreamPlayer.new()
	sfx_game_over.name = "SFXGameOver"
	sfx_game_over.stream = load("res://assets/audio/SFX_GAME OVER.mp3")
	sfx_game_over.bus = &"SFX"
	sfx_game_over.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(sfx_game_over)

func _process(_delta: float) -> void:
	if not Global.EstadodoVivo and not visible:
		mostrar()
	elif visible and Global.gameoveractivo:
		if has_node("VBoxContainer/HBoxContainer/btnReiniciar"):
			$VBoxContainer/HBoxContainer/btnReiniciar.grab_focus()
		Global.gameoveractivo = false

func mostrar() -> void:
	visible = true
	if has_node("ColorRect"):
		$ColorRect.visible = true
	if has_node("VBoxContainer"):
		$VBoxContainer.visible = true
	get_tree().paused = true
	Global.EstadodoVivo = false
	Global.bloquear_pausa = true
	Global.gameoveractivo = true
	if has_node("VBoxContainer/HBoxContainer/btnReiniciar"):
		$VBoxContainer/HBoxContainer/btnReiniciar.grab_focus()
	if ocultar:
		ocultar.visible = false
	if sfx_game_over:
		sfx_game_over.play()

func _on_btn_reiniciar_pressed() -> void:
	if sfx_game_over and sfx_game_over.playing:
		sfx_game_over.stop()
	visible = false
	if has_node("ColorRect"):
		$ColorRect.visible = false
	if has_node("VBoxContainer"):
		$VBoxContainer.visible = false
	get_tree().paused = false
	Global.EstadodoVivo = true
	Global.vidaJugador = 10
	Global.bloquear_pausa = false
	Global.gameoveractivo = false
	if ReinicioEscena != "":
		Global.cambiar_escena(ReinicioEscena)
	else:
		Global.recargar_escena()

func _on_btn_salir_menu_pressed() -> void:
	if sfx_game_over and sfx_game_over.playing:
		sfx_game_over.stop()
	visible = false
	if has_node("ColorRect"):
		$ColorRect.visible = false
	if has_node("VBoxContainer"):
		$VBoxContainer.visible = false
	get_tree().paused = false
	Global.EstadodoVivo = true
	Global.vidaJugador = 10
	Global.bloquear_pausa = false
	Global.gameoveractivo = false
	Global.deberRestaurarPosicion = false
	Global.posicionJugador = Vector2.ZERO
	Global.posicionAudio = 0.0
	Global.deberRestaurarAudio = false
	Global.cambiar_escena("res://escenas/ui/menu.tscn")
