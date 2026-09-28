extends CanvasLayer

const MAX_VOLUMEN_MUSICA: float = 0.75

@export var ocultar: Control
@onready var checkPantalla: CheckButton = $Panel/VBoxContainer2/HBoxContainer/CheckButton
@onready var sliderMusica: HSlider = $Panel/VBoxContainer2/HBoxContainer3/MusicaSlider
@onready var sliderSfx: HSlider = $Panel/VBoxContainer2/HBoxContainer2/SFXSlider

var encendido: bool = false

func _ready() -> void:
	visible = false
	checkPantalla.button_pressed = Global.pantallaCompleta
	
	var busMusica = AudioServer.get_bus_index("Musica")
	if busMusica != -1:
		var db = AudioServer.get_bus_volume_db(busMusica)
		sliderMusica.value = 0.0 if db <= -79.0 else clamp(db_to_linear(db) / MAX_VOLUMEN_MUSICA, 0.0, 1.0)
		
	var busSfx = AudioServer.get_bus_index("SFX")
	if busSfx != -1:
		var dbSfx = AudioServer.get_bus_volume_db(busSfx)
		sliderSfx.value = 0.0 if dbSfx <= -79.0 else db_to_linear(dbSfx)

func _process(_delta: float) -> void:
	if visible and encendido:
		sliderMusica.grab_focus()
		encendido = false

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Pausa") and not Global.bloquearPausa:
		toggle_pausa()

func toggle_pausa() -> void:
	var pausado = !get_tree().paused
	get_tree().paused = pausado
	visible = pausado
	encendido = pausado
	if ocultar:
		ocultar.visible = !pausado

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
	Global.pantallaCompleta = toggled_on
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if toggled_on else DisplayServer.WINDOW_MODE_WINDOWED)

func _on_musica_slider_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("Musica")
	if bus != -1:
		AudioServer.set_bus_volume_db(bus, -80.0 if value <= 0.001 else linear_to_db(value * MAX_VOLUMEN_MUSICA))

func _on_sfx_slider_value_changed(value: float) -> void:
	var bus = AudioServer.get_bus_index("SFX")
	if bus != -1:
		AudioServer.set_bus_volume_db(bus, -80.0 if value <= 0.001 else linear_to_db(value))
