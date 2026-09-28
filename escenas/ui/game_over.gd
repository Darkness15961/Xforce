extends CanvasLayer

@export_file("*.tscn") var ReinicioEscena: String
@export var ocultar: Control

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

func _on_btn_reiniciar_pressed() -> void:
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
		get_tree().change_scene_to_file(ReinicioEscena)
	else:
		get_tree().reload_current_scene()

func _on_btn_salir_menu_pressed() -> void:
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
	get_tree().change_scene_to_file("res://escenas/ui/menu.tscn")
