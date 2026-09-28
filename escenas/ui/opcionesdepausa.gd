extends CanvasLayer

const MAX_VOLUMEN_MUSICA: float = 0.75

var encendido: bool = false
@export var ocultar: Control

func _ready() -> void:
	$Panel/VBoxContainer2/HBoxContainer/CheckButton.button_pressed = Global.pantallaCompleta
	
	var busMusica = AudioServer.get_bus_index("Musica")
	if busMusica != -1:
		var volumenDb = AudioServer.get_bus_volume_db(busMusica)
		if volumenDb <= -79.0:
			$Panel/VBoxContainer2/HBoxContainer3/MusicaSlider.value = 0.0
		else:
			var volumenLineal = db_to_linear(volumenDb)
			$Panel/VBoxContainer2/HBoxContainer3/MusicaSlider.value = clamp(volumenLineal / MAX_VOLUMEN_MUSICA, 0.0, 1.0)
		
	var busSfx = AudioServer.get_bus_index("SFX")
	if busSfx != -1:
		var volumenDbSfx = AudioServer.get_bus_volume_db(busSfx)
		if volumenDbSfx <= -79.0:
			$Panel/VBoxContainer2/HBoxContainer2/SFXSlider.value = 0.0
		else:
			$Panel/VBoxContainer2/HBoxContainer2/SFXSlider.value = db_to_linear(volumenDbSfx)

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
	Global.posicionAudio = 0.0
	Global.deberRestaurarAudio = false
	Global.deberRestaurarPosicion = false
	Global.posicionJugador = Vector2.ZERO
	Global.cambiar_escena("res://escenas/ui/menu.tscn")

func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		Global.pantallaCompleta = true
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		Global.pantallaCompleta = false
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pausa"):
		if Global.bloquearPausa:
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
	var indiceBus = AudioServer.get_bus_index("Musica")
	if indiceBus != -1:
		if value <= 0.001:
			AudioServer.set_bus_volume_db(indiceBus, -80.0)
		else:
			var volumenReal = value * MAX_VOLUMEN_MUSICA
			AudioServer.set_bus_volume_db(indiceBus, linear_to_db(volumenReal))

func _on_sfx_slider_value_changed(value: float) -> void:
	var indiceBus = AudioServer.get_bus_index("SFX")
	if indiceBus != -1:
		if value <= 0.001:
			AudioServer.set_bus_volume_db(indiceBus, -80.0)
		else:
			AudioServer.set_bus_volume_db(indiceBus, linear_to_db(value))
