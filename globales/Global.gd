extends Node

# Posición y persistencia entre dimensiones
var posicionJugador: Vector2 = Vector2.ZERO
var deberRestaurarPosicion: bool = false

# Música y persistencia de audio
var posicionAudio: float = 0.0
var deberRestaurarAudio: bool = false

# Estado del jugador y vida
var vidaJugador: int = 10
var EstadodoVivo: bool = true
var gameoveractivo: bool = false

# Ajustes generales y pausa
var pantallaCompleta: bool = false
var bloquear_pausa: bool = false

# Estado del menú principal
var animacion_inicial_menu_vista: bool = false

# Reproductor de música persistente para Menú y Créditos
var reproductorMusicaMenu: AudioStreamPlayer = null

# Estado de diálogo
var en_dialogo: bool = false

# Señales para actualización reactiva de la interfaz
signal item_chicha_cambiado(nueva_cantidad: int)
signal item_celular_cambiado(nueva_cantidad: int)

# Variables contador de Items con reactividad global
var Item_Celular: int = 0:
	set(valor):
		Item_Celular = maxi(0, valor)
		item_celular_cambiado.emit(Item_Celular)

var Item_Chica: int = 0:
	set(valor):
		Item_Chica = maxi(0, valor)
		item_chicha_cambiado.emit(Item_Chica)

# Alias de compatibilidad para Item_Chicha (con 'h')
var Item_Chicha: int:
	get:
		return Item_Chica
	set(valor):
		Item_Chica = valor

func agregar_chicha(cantidad: int = 1) -> void:
	Item_Chica += cantidad

func consumir_chicha(cantidad: int = 1) -> bool:
	if Item_Chica >= cantidad:
		Item_Chica -= cantidad
		return true
	return false

func agregar_celular(cantidad: int = 1) -> void:
	Item_Celular += cantidad

func consumir_celular(cantidad: int = 1) -> bool:
	if Item_Celular >= cantidad:
		Item_Celular -= cantidad
		return true
	return false

func reproducir_musica_menu() -> void:
	if reproductorMusicaMenu == null:
		reproductorMusicaMenu = AudioStreamPlayer.new()
		reproductorMusicaMenu.name = "MusicaMenuGlobal"
		var stream = load("res://assets/audio/SAMIY-GAMEJAM-OST-1.mp3")
		if stream is AudioStreamMP3:
			stream.loop = true
		reproductorMusicaMenu.stream = stream
		reproductorMusicaMenu.bus = &"Musica"
		reproductorMusicaMenu.finished.connect(_on_musica_menu_finished)
		add_child(reproductorMusicaMenu)
	
	if not reproductorMusicaMenu.playing:
		reproductorMusicaMenu.play()

func _on_musica_menu_finished() -> void:
	if reproductorMusicaMenu:
		reproductorMusicaMenu.play()

func detener_musica_menu() -> void:
	if reproductorMusicaMenu and reproductorMusicaMenu.playing:
		reproductorMusicaMenu.stop()

# Sistema de transición con Fade Out / Fade In universal entre escenas
var capa_transicion: CanvasLayer = null
var rect_fade: ColorRect = null
var en_transicion: bool = false

func _ready() -> void:
	_crear_capa_transicion()
	_inicializar_volumen_musica()
	_conectar_dialogue_manager()

func _conectar_dialogue_manager() -> void:
	if Engine.has_singleton("DialogueManager"):
		var dm = Engine.get_singleton("DialogueManager")
		if not dm.dialogue_started.is_connected(_on_dialogue_started):
			dm.dialogue_started.connect(_on_dialogue_started)
		if not dm.dialogue_ended.is_connected(_on_dialogue_ended):
			dm.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_started(_resource: Variant = null) -> void:
	en_dialogo = true

func _on_dialogue_ended(_resource: Variant = null) -> void:
	en_dialogo = false

func _inicializar_volumen_musica() -> void:
	var bus_musica = AudioServer.get_bus_index("Musica")
	if bus_musica != -1:
		AudioServer.set_bus_volume_db(bus_musica, linear_to_db(0.75))

func _crear_capa_transicion() -> void:
	if capa_transicion != null and is_instance_valid(capa_transicion):
		return
	
	capa_transicion = CanvasLayer.new()
	capa_transicion.name = "CapaTransicionGlobal"
	capa_transicion.layer = 128
	capa_transicion.process_mode = Node.PROCESS_MODE_ALWAYS
	
	rect_fade = ColorRect.new()
	rect_fade.name = "FadeRect"
	rect_fade.set_anchors_preset(Control.PRESET_FULL_RECT)
	rect_fade.grow_horizontal = Control.GROW_DIRECTION_BOTH
	rect_fade.grow_vertical = Control.GROW_DIRECTION_BOTH
	rect_fade.color = Color(0, 0, 0, 0)
	rect_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect_fade.process_mode = Node.PROCESS_MODE_ALWAYS
	
	capa_transicion.add_child(rect_fade)
	add_child(capa_transicion)

func cambiar_escena(ruta_escena: String, duracion: float = 0.25, sincronizar_audio: bool = true) -> void:
	if en_transicion:
		return
	en_transicion = true
	
	_crear_capa_transicion()
	rect_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 1. Fade Out (de transparente a negro)
	var tween_out = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_out.tween_property(rect_fade, "color:a", 1.0, duracion)
	await tween_out.finished
	
	# Guardar posición de audio solo si se requiere sincronización interdimensional
	if not sincronizar_audio:
		posicionAudio = 0.0
		deberRestaurarAudio = false
	else:
		var escena_actual = get_tree().current_scene
		if escena_actual:
			var audio = escena_actual.get_node_or_null("AudioStreamPlayer")
			if audio and audio is AudioStreamPlayer and audio.playing:
				posicionAudio = audio.get_playback_position()
				deberRestaurarAudio = true
	
	# Si la escena de destino es un nivel de juego, apagar la música del menú
	if not ruta_escena.contains("menu") and not ruta_escena.contains("Creditos"):
		detener_musica_menu()
	
	# Despausar el árbol si estaba en pausa
	if get_tree().paused:
		get_tree().paused = false
	
	# 2. Cambiar a la nueva escena
	get_tree().change_scene_to_file(ruta_escena)
	
	# Esperar dos frames a que la nueva escena se monte e inicialice
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 3. Fade In (de negro a transparente)
	var tween_in = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_in.tween_property(rect_fade, "color:a", 0.0, duracion)
	await tween_in.finished
	
	rect_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	en_transicion = false

func recargar_escena(duracion: float = 0.25) -> void:
	if en_transicion:
		return
	en_transicion = true
	
	_crear_capa_transicion()
	rect_fade.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 1. Fade Out
	var tween_out = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_out.tween_property(rect_fade, "color:a", 1.0, duracion)
	await tween_out.finished
	
	if get_tree().paused:
		get_tree().paused = false
	
	# 2. Recargar escena actual
	get_tree().reload_current_scene()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 3. Fade In
	var tween_in = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween_in.tween_property(rect_fade, "color:a", 0.0, duracion)
	await tween_in.finished
	
	rect_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	en_transicion = false
