extends CanvasLayer

@export_file("*.tscn") var ReinicioEscena: String
@export var ocultar: Control
func _ready() -> void:
	Global.gameoveractivo = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	
	if $".".visible and Global.gameoveractivo == true:
		$VBoxContainer/HBoxContainer/btnReiniciar.grab_focus()
		ocultar.visible = false
		Global.gameoveractivo = false
	if Global.EstadodoVivo == false:
		get_tree().paused = true
		$".".visible = true

func _on_btn_reiniciar_pressed() -> void:
	$".".visible = false
	get_tree().paused = false
	Global.EstadodoVivo = true
	Global.vidaJugador = 10
	get_tree().change_scene_to_file(ReinicioEscena)

func _on_btn_salir_menu_pressed() -> void:
	get_tree().paused = false
	Global.EstadodoVivo = true
	Global.vidaJugador = 10
	get_tree().change_scene_to_file("res://MenuPrincipal/escenas/MenuPrincipal.tscn")
