extends Node

# Variables globales de juego
var posicionJugador: Vector2 = Vector2.ZERO
var deberRestaurarPosicion: bool = false
var posicionAudio: float = 0.0
var deberRestaurarAudio: bool = false

var vidaJugador: int = 10
var estadoVivo: bool = true
var gameOverActivo: bool = false
var pantallaCompleta: bool = false
var bloquearPausa: bool = false
var animacionInicialMenuVista: bool = false
var enDialogo: bool = false
var enTransicion: bool = false

# Items con señales reactivas
signal item_chicha_cambiado(nuevaCantidad: int)
signal item_celular_cambiado(nuevaCantidad: int)

var itemCelular: int = 0:
	set(valor):
		itemCelular = maxi(0, valor)
		item_celular_cambiado.emit(itemCelular)

var itemChicha: int = 0:
	set(valor):
		itemChicha = maxi(0, valor)
		item_chicha_cambiado.emit(itemChicha)

func agregar_chicha(cantidad: int = 1) -> void:
	itemChicha += cantidad

func consumir_chicha(cantidad: int = 1) -> bool:
	if itemChicha >= cantidad:
		itemChicha -= cantidad
		return true
	return false

func agregar_celular(cantidad: int = 1) -> void:
	itemCelular += cantidad

func consumir_celular(cantidad: int = 1) -> bool:
	if itemCelular >= cantidad:
		itemCelular -= cantidad
		return true
	return false

# Musica de menu
var reproductorMusicaMenu: AudioStreamPlayer = null

func reproducir_musica_menu() -> void:
	if not reproductorMusicaMenu:
		reproductorMusicaMenu = AudioStreamPlayer.new()
		reproductorMusicaMenu.name = "MusicaMenuGlobal"
		var flujo = load("res://assets/audio/SAMIY-GAMEJAM-OST-1.mp3")
		if flujo is AudioStreamMP3:
			flujo.loop = true
		reproductorMusicaMenu.stream = flujo
		reproductorMusicaMenu.bus = &"Musica"
		add_child(reproductorMusicaMenu)
	if not reproductorMusicaMenu.playing:
		reproductorMusicaMenu.play()

func detener_musica_menu() -> void:
	if reproductorMusicaMenu and reproductorMusicaMenu.playing:
		reproductorMusicaMenu.stop()

# Transicion de pantalla (Fade)
var capaTransicion: CanvasLayer = null
var rectDesvanecer: ColorRect = null

func _ready() -> void:
	_crear_capa_transicion()
	var busMusica = AudioServer.get_bus_index("Musica")
	if busMusica != -1:
		AudioServer.set_bus_volume_db(busMusica, linear_to_db(0.75))
	
	if Engine.has_singleton("DialogueManager"):
		var dm = Engine.get_singleton("DialogueManager")
		dm.dialogue_started.connect(func(_r = null): enDialogo = true)
		dm.dialogue_ended.connect(func(_r = null): enDialogo = false)

func _crear_capa_transicion() -> void:
	if capaTransicion and is_instance_valid(capaTransicion):
		return
	capaTransicion = CanvasLayer.new()
	capaTransicion.layer = 128
	capaTransicion.process_mode = Node.PROCESS_MODE_ALWAYS
	
	rectDesvanecer = ColorRect.new()
	rectDesvanecer.set_anchors_preset(Control.PRESET_FULL_RECT)
	rectDesvanecer.color = Color(0, 0, 0, 0)
	rectDesvanecer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rectDesvanecer.process_mode = Node.PROCESS_MODE_ALWAYS
	
	capaTransicion.add_child(rectDesvanecer)
	add_child(capaTransicion)

func cambiar_escena(rutaEscena: String, duracion: float = 0.25, sincronizarAudio: bool = true) -> void:
	if enTransicion:
		return
	enTransicion = true
	_crear_capa_transicion()
	rectDesvanecer.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# Guardar audio si corresponde
	if sincronizarAudio:
		var actual = get_tree().current_scene
		if actual:
			var audio = actual.get_node_or_null("AudioStreamPlayer")
			if audio and audio is AudioStreamPlayer and audio.playing:
				posicionAudio = audio.get_playback_position()
				deberRestaurarAudio = true
	else:
		posicionAudio = 0.0
		deberRestaurarAudio = false

	if not rutaEscena.contains("menu") and not rutaEscena.contains("Creditos"):
		detener_musica_menu()

	# Fade Out -> Cambiar -> Fade In
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(rectDesvanecer, "color:a", 1.0, duracion)
	await tween.finished
	
	get_tree().paused = false
	get_tree().change_scene_to_file(rutaEscena)
	await get_tree().process_frame
	await get_tree().process_frame
	
	var tweenIn = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tweenIn.tween_property(rectDesvanecer, "color:a", 0.0, duracion)
	await tweenIn.finished
	
	rectDesvanecer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	enTransicion = false

func recargar_escena(duracion: float = 0.25) -> void:
	if enTransicion:
		return
	enTransicion = true
	_crear_capa_transicion()
	rectDesvanecer.mouse_filter = Control.MOUSE_FILTER_STOP
	
	var tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(rectDesvanecer, "color:a", 1.0, duracion)
	await tween.finished
	
	get_tree().paused = false
	get_tree().reload_current_scene()
	await get_tree().process_frame
	await get_tree().process_frame
	
	var tweenIn = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tweenIn.tween_property(rectDesvanecer, "color:a", 0.0, duracion)
	await tweenIn.finished
	
	rectDesvanecer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	enTransicion = false
