extends CanvasLayer

var encendido: bool = false
@export var ocultar: Control

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Panel/VBoxContainer2/HBoxContainer/CheckButton.button_pressed = Global.pantallaCompleta


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if $".".visible and encendido == true:
		$Panel/VBoxContainer2/HBoxContainer3/MusicaSlider.grab_focus()
		encendido = false
		ocultar.visible = false


func _on_btn_salir_opc_pressed() -> void:
	toggle_pausa()


func _on_btn_salir_menu_pressed() -> void:
	toggle_pausa()
	get_tree().change_scene_to_file("res://MenuPrincipal/escenas/MenuPrincipal.tscn")


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on == true:
		Global.pantallaCompleta = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		Global.pantallaCompleta = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pausa"):
		# Verificamos si la pausa está bloqueada por la elección final
		if Global.bloquear_pausa == true:
			return # Si está bloqueada, cancelamos la ejecución aquí mismo
			
		toggle_pausa()
		ocultar.visible = true
		encendido = true

func toggle_pausa():
	var nuevoEstado = !get_tree().paused
	get_tree().paused = nuevoEstado
	visible = nuevoEstado


func _on_musica_slider_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Musica")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))


func _on_sfx_slider_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("SFX")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))
