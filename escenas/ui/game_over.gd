extends CanvasLayer

@export_file("*.tscn") var reinicioEscena: String = ""
@export var ocultar: Control
@onready var btnReiniciar: Button = get_node_or_null("VBoxContainer/HBoxContainer/btnReiniciar")

var sfxGameOver: AudioStreamPlayer = null

func _ready() -> void:
	add_to_group("GameOver")
	visible = false
	Global.estadoVivo = true
	Global.bloquearPausa = false
	Global.gameOverActivo = false
	
	sfxGameOver = AudioStreamPlayer.new()
	sfxGameOver.stream = load("res://assets/audio/SFX_GAME OVER.mp3")
	sfxGameOver.bus = &"SFX"
	sfxGameOver.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(sfxGameOver)

func _process(_delta: float) -> void:
	if not Global.estadoVivo and not visible:
		mostrar()

func mostrar() -> void:
	visible = true
	get_tree().paused = true
	Global.estadoVivo = false
	Global.bloquearPausa = true
	Global.gameOverActivo = true
	if btnReiniciar:
		btnReiniciar.grab_focus()
	if ocultar:
		ocultar.visible = false
	if sfxGameOver:
		sfxGameOver.play()

func _on_btn_reiniciar_pressed() -> void:
	if sfxGameOver and sfxGameOver.playing:
		sfxGameOver.stop()
	visible = false
	get_tree().paused = false
	Global.estadoVivo = true
	Global.vidaJugador = 10
	Global.bloquearPausa = false
	Global.gameOverActivo = false
	if not reinicioEscena.is_empty():
		Global.cambiar_escena(reinicioEscena)
	else:
		Global.recargar_escena()

func _on_btn_salir_menu_pressed() -> void:
	if sfxGameOver and sfxGameOver.playing:
		sfxGameOver.stop()
	visible = false
	get_tree().paused = false
	Global.estadoVivo = true
	Global.vidaJugador = 10
	Global.bloquearPausa = false
	Global.gameOverActivo = false
	Global.deberRestaurarPosicion = false
	Global.posicionJugador = Vector2.ZERO
	Global.posicionAudio = 0.0
	Global.deberRestaurarAudio = false
	Global.cambiar_escena("res://escenas/ui/menu.tscn")
