extends CanvasLayer

var encendido: bool = false
@export var ocultar: Control

func _ready() -> void:
	$Panel/VBoxContainer2/HBoxContainer/CheckButton.button_pressed = Global.pantallaCompleta

func _process(_delta: float) -> void:
	if visible and encendido:
		$Panel/VBoxContainer2/HBoxContainer3/MusicaSlider.grab_focus()
		encendido = false
		if ocultar:
			ocultar.visible = false

func _on_btn_salir_opc_pressed() -> void:
	toggle_pausa()

func _on_btn_salir_menu_pressed() -> void:
	toggle_pausa()
	get_tree().change_scene_to_file("res://menu/menu.tscn")

func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.pantallaCompleta = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		Global.pantallaCompleta = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pausa"):
		if Global.bloquear_pausa:
			return
			
		toggle_pausa()

func toggle_pausa() -> void:
	var nuevoEstado = !get_tree().paused
	get_tree().paused = nuevoEstado
	visible = nuevoEstado
	
	if nuevoEstado:
		encendido = true
		if ocultar:
			ocultar.visible = false
	else:
		if ocultar:
			ocultar.visible = true

func _on_musica_slider_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("Musica")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	var bus_idx = AudioServer.get_bus_index("SFX")
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))

