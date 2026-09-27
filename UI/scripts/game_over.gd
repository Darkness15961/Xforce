extends CanvasLayer

@export_file("*.tscn") var ReinicioEscena: String
@export var ocultar: Control

func _ready() -> void:
	Global.gameoveractivo = true

func _process(_delta: float) -> void:
	if visible and Global.gameoveractivo:
		$VBoxContainer/HBoxContainer/btnReiniciar.grab_focus()
		if ocultar:
			ocultar.visible = false
		Global.gameoveractivo = false

	if not Global.EstadodoVivo and not visible:
		get_tree().paused = true
		visible = true
		Global.gameoveractivo = true

func _on_btn_reiniciar_pressed() -> void:
	visible = false
	get_tree().paused = false
	Global.EstadodoVivo = true
	Global.vidaJugador = 10
	if ReinicioEscena != "":
		get_tree().change_scene_to_file(ReinicioEscena)
	else:
		get_tree().reload_current_scene()

func _on_btn_salir_menu_pressed() -> void:
	get_tree().paused = false
	Global.EstadodoVivo = true
	Global.vidaJugador = 10
	get_tree().change_scene_to_file("res://menu/menu.tscn")

