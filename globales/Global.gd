extends Node

# Posicion y persistencia entre dimensiones
var posicionJugador: Vector2 = Vector2.ZERO
var deberRestaurarPosicion: bool = false

# Musica y persistencia de audio
var posicionAudio: float = 0.0
var deberRestaurarAudio: bool = false

# Estado del jugador y vida
var vidaJugador: int = 10
var estadoVivo: bool = true
var gameOverActivo: bool = false

# Ajustes generales y pausa
var pantallaCompleta: bool = false
var bloquearPausa: bool = false

# Estado del menu principal
var animacionInicialMenuVista: bool = false

# Reproductor de musica persistente para Menu y Creditos
var reproductorMusicaMenu: AudioStreamPlayer = null

# Estado de dialogo
var enDialogo: bool = false

# Señales para actualizacion reactiva de la interfaz
signal item_chicha_cambiado(nueva_cantidad: int)
signal item_celular_cambiado(nueva_cantidad: int)

# Variables contador de Items con reactividad global
var itemCelular: int = 0:
	set(valor):
		itemCelular = maxi(0, valor)
		item_celular_cambiado.emit(itemCelular)

var itemChicha: int = 0:
	set(valor):
		itemChicha = maxi(0, valor)
		item_chicha_cambiado.emit(itemChicha)

#region Alias de compatibilidad
var Item_Celular: int:
	get: return itemCelular
	set(valor): itemCelular = valor

var Item_Chica: int:
	get: return itemChicha
	set(valor): itemChicha = valor

var Item_Chicha: int:
	get: return itemChicha
	set(valor): itemChicha = valor

var EstadodoVivo: bool:
	get: return estadoVivo
	set(valor): estadoVivo = valor

var gameoveractivo: bool:
	get: return gameOverActivo
	set(valor): gameOverActivo = valor

var bloquear_pausa: bool:
	get: return bloquearPausa
	set(valor): bloquearPausa = valor

var animacion_inicial_menu_vista: bool:
	get: return animacionInicialMenuVista
	set(valor): animacionInicialMenuVista = valor

var en_dialogo: bool:
	get: return enDialogo
	set(valor): enDialogo = valor

var en_transicion: bool:
	get: return enTransicion
	set(valor): enTransicion = valor

var capa_transicion: CanvasLayer:
	get: return capaTransicion
	set(valor): capaTransicion = valor

var rect_fade: ColorRect:
	get: return rectDesvanecer
	set(valor): rectDesvanecer = valor
#endregion

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

func reproducir_musica_menu() -> void:
	if reproductorMusicaMenu == null:
		reproductorMusicaMenu = AudioStreamPlayer.new()
		reproductorMusicaMenu.name = "MusicaMenuGlobal"
		var flujoAudio = load("res://assets/audio/SAMIY-GAMEJAM-OST-1.mp3")
		if flujoAudio is AudioStreamMP3:
			flujoAudio.loop = true
		reproductorMusicaMenu.stream = flujoAudio
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

# Sistema de transicion con Fade Out / Fade In universal entre escenas
var capaTransicion: CanvasLayer = null
var rectDesvanecer: ColorRect = null
var enTransicion: bool = false

func _ready() -> void:
	_crear_capa_transicion()
	_inicializar_volumen_musica()
	_conectar_dialogue_manager()

func _conectar_dialogue_manager() -> void:
	if Engine.has_singleton("DialogueManager"):
		var gestorDialogo = Engine.get_singleton("DialogueManager")
		if not gestorDialogo.dialogue_started.is_connected(_on_dialogue_started):
			gestorDialogo.dialogue_started.connect(_on_dialogue_started)
		if not gestorDialogo.dialogue_ended.is_connected(_on_dialogue_ended):
			gestorDialogo.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_started(_resource: Variant = null) -> void:
	enDialogo = true

func _on_dialogue_ended(_resource: Variant = null) -> void:
	enDialogo = false

func _inicializar_volumen_musica() -> void:
	var busMusica = AudioServer.get_bus_index("Musica")
	if busMusica != -1:
		AudioServer.set_bus_volume_db(busMusica, linear_to_db(0.75))

func _crear_capa_transicion() -> void:
	if capaTransicion != null and is_instance_valid(capaTransicion):
		return
	
	capaTransicion = CanvasLayer.new()
	capaTransicion.name = "CapaTransicionGlobal"
	capaTransicion.layer = 128
	capaTransicion.process_mode = Node.PROCESS_MODE_ALWAYS
	
	rectDesvanecer = ColorRect.new()
	rectDesvanecer.name = "FadeRect"
	rectDesvanecer.set_anchors_preset(Control.PRESET_FULL_RECT)
	rectDesvanecer.grow_horizontal = Control.GROW_DIRECTION_BOTH
	rectDesvanecer.grow_vertical = Control.GROW_DIRECTION_BOTH
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
	
	# 1. Fade Out (de transparente a negro)
	var tweenSalida = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tweenSalida.tween_property(rectDesvanecer, "color:a", 1.0, duracion)
	await tweenSalida.finished
	
	# Guardar posicion de audio solo si se requiere sincronizacion interdimensional
	if not sincronizarAudio:
		posicionAudio = 0.0
		deberRestaurarAudio = false
	else:
		var escenaActual = get_tree().current_scene
		if escenaActual:
			var reproductorAudioNivel = escenaActual.get_node_or_null("AudioStreamPlayer")
			if reproductorAudioNivel and reproductorAudioNivel is AudioStreamPlayer and reproductorAudioNivel.playing:
				posicionAudio = reproductorAudioNivel.get_playback_position()
				deberRestaurarAudio = true
	
	# Si la escena de destino es un nivel de juego, apagar la musica del menu
	if not rutaEscena.contains("menu") and not rutaEscena.contains("Creditos"):
		detener_musica_menu()
	
	# Despausar el arbol si estaba en pausa
	if get_tree().paused:
		get_tree().paused = false
	
	# 2. Cambiar a la nueva escena
	get_tree().change_scene_to_file(rutaEscena)
	
	# Esperar dos frames a que la nueva escena se monte e inicialice
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 3. Fade In (de negro a transparente)
	var tweenEntrada = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tweenEntrada.tween_property(rectDesvanecer, "color:a", 0.0, duracion)
	await tweenEntrada.finished
	
	rectDesvanecer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	enTransicion = false

func recargar_escena(duracion: float = 0.25) -> void:
	if enTransicion:
		return
	enTransicion = true
	
	_crear_capa_transicion()
	rectDesvanecer.mouse_filter = Control.MOUSE_FILTER_STOP
	
	# 1. Fade Out
	var tweenSalida = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tweenSalida.tween_property(rectDesvanecer, "color:a", 1.0, duracion)
	await tweenSalida.finished
	
	if get_tree().paused:
		get_tree().paused = false
	
	# 2. Recargar escena actual
	get_tree().reload_current_scene()
	
	await get_tree().process_frame
	await get_tree().process_frame
	
	# 3. Fade In
	var tweenEntrada = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tweenEntrada.tween_property(rectDesvanecer, "color:a", 0.0, duracion)
	await tweenEntrada.finished
	
	rectDesvanecer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	enTransicion = false
