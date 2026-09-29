extends CanvasLayer
## A basic dialogue balloon for use with Dialogue Manager.


## The dialogue resource
@export var dialogue_resource: DialogueResource

## Start from a given cue when using balloon as a [Node] in a scene.
@export var start_from_cue: String = ""

## If running as a [Node] in a scene then auto start the dialogue.
@export var auto_start: bool = false

## If all other input is blocked as long as dialogue is shown.
@export var will_block_other_input: bool = true

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"

## A sound player for voice lines (if they exist).
@onready var audio_stream_player: AudioStreamPlayer = %AudioStreamPlayer

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## A dictionary to store any ephemeral variables
var locals: Dictionary = {}

var _locale: String = TranslationServer.get_locale()

## The current line
var dialogue_line: DialogueLine:
	set(value):
		if value:
			dialogue_line = value
			apply_dialogue_line()
		else:
			if audio_stream_player and audio_stream_player.playing:
				audio_stream_player.stop()
			_restaurar_musica()
			# The dialogue has finished so close the balloon
			if owner == null:
				queue_free()
			else:
				hide()
	get:
		return dialogue_line

## A cooldown timer for delaying the balloon hide when encountering a mutation.
var mutation_cooldown: Timer = Timer.new()

## The base balloon anchor
@onready var balloon: Control = %Balloon

## The label showing the name of the currently speaking character
@onready var character_label: RichTextLabel = %CharacterLabel

## The label showing the currently spoken dialogue
@onready var dialogue_label: DialogueLabel = %DialogueLabel

## The menu of responses
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

## Indicator to show that player can progress dialogue.
@onready var progress: Polygon2D = %Progress

## Contenedores principales del dialogo para reposicionar en pantalla
@onready var margin_container: MarginContainer = %MarginContainer
@onready var panel_container: PanelContainer = %PanelContainer

# Ducking de musica al 40% durante dialogos
var _bus_musica_idx: int = -1
var _volumen_musica_base_db: float = 0.0
var _musica_atenuada: bool = false
var _tween_musica: Tween
var _tween_pos: Tween


func _ready() -> void:
	_bus_musica_idx = AudioServer.get_bus_index(&"Musica")
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action

	mutation_cooldown.timeout.connect(_on_mutation_cooldown_timeout)
	add_child(mutation_cooldown)

	if auto_start:
		if not is_instance_valid(dialogue_resource):
			assert(false, DMConstants.get_error_message(DMConstants.ERR_MISSING_RESOURCE_FOR_AUTOSTART))
		start()


func _exit_tree() -> void:
	_restaurar_musica_inmediato()


func _process(_delta: float) -> void:
	if is_instance_valid(dialogue_line):
		var voice_playing: bool = audio_stream_player and audio_stream_player.playing
		progress.visible = not dialogue_label.is_typing and dialogue_line.responses.size() == 0 and not voice_playing and is_waiting_for_input


func _unhandled_input(event: InputEvent) -> void:
	# If voice is playing, DO NOT allow skipping or advancing the dialogue!
	if audio_stream_player and audio_stream_player.playing:
		get_viewport().set_input_as_handled()
		return

	if is_waiting_for_input and is_instance_valid(dialogue_line) and dialogue_line.responses.size() == 0:
		if event.is_action_pressed(next_action) or event.is_action_pressed(&"jump") or (event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT):
			get_viewport().set_input_as_handled()
			is_waiting_for_input = false
			next(dialogue_line.next_id)
			return

	# Only the balloon is allowed to handle input while it's showing
	if will_block_other_input:
		get_viewport().set_input_as_handled()


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio: float = dialogue_label.visible_ratio
		await dialogue_line.refresh()
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
func start(with_dialogue_resource: DialogueResource = null, cue: String = "", extra_game_states: Array = []) -> void:
	temporary_game_states = [self] + extra_game_states
	is_waiting_for_input = false
	if is_instance_valid(with_dialogue_resource):
		dialogue_resource = with_dialogue_resource
	if not cue.is_empty():
		start_from_cue = cue
	_atenuar_musica()
	dialogue_line = await dialogue_resource.get_next_dialogue_line(start_from_cue, temporary_game_states)
	show()


func _cargar_audio_voz(path: String) -> AudioStream:
	if ResourceLoader.exists(path):
		var res = load(path)
		if res is AudioStream:
			return res
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var stream = AudioStreamMP3.new()
			stream.data = file.get_buffer(file.get_length())
			return stream
	return null


func _atenuar_musica() -> void:
	if _musica_atenuada:
		return
	if _bus_musica_idx == -1:
		_bus_musica_idx = AudioServer.get_bus_index(&"Musica")
	if _bus_musica_idx == -1:
		return

	_volumen_musica_base_db = AudioServer.get_bus_volume_db(_bus_musica_idx)
	_musica_atenuada = true
	# Reducir al 40% del volumen lineal (aprox -7.96 dB respecto al nivel base)
	var volumen_duck_db: float = _volumen_musica_base_db + linear_to_db(0.40)
	if _tween_musica and _tween_musica.is_valid():
		_tween_musica.kill()
	_tween_musica = create_tween()
	_tween_musica.tween_method(
		func(val: float) -> void: AudioServer.set_bus_volume_db(_bus_musica_idx, val),
		AudioServer.get_bus_volume_db(_bus_musica_idx),
		volumen_duck_db,
		0.25
	)


func _restaurar_musica() -> void:
	if not _musica_atenuada:
		return
	if _bus_musica_idx == -1:
		_bus_musica_idx = AudioServer.get_bus_index(&"Musica")
	if _bus_musica_idx == -1:
		return

	_musica_atenuada = false
	if _tween_musica and _tween_musica.is_valid():
		_tween_musica.kill()
	_tween_musica = create_tween()
	_tween_musica.tween_method(
		func(val: float) -> void: AudioServer.set_bus_volume_db(_bus_musica_idx, val),
		AudioServer.get_bus_volume_db(_bus_musica_idx),
		_volumen_musica_base_db,
		0.4
	)


func _restaurar_musica_inmediato() -> void:
	if not _musica_atenuada:
		return
	if _bus_musica_idx == -1:
		_bus_musica_idx = AudioServer.get_bus_index(&"Musica")
	if _bus_musica_idx != -1:
		AudioServer.set_bus_volume_db(_bus_musica_idx, _volumen_musica_base_db)
	_musica_atenuada = false


func _es_dialogo_intro_o_final() -> bool:
	if dialogue_resource and not dialogue_resource.resource_path.is_empty():
		var path: String = dialogue_resource.resource_path.to_lower()
		if "intro" in path or "final" in path:
			return true
	for state in temporary_game_states:
		if is_instance_valid(state):
			var script_path: String = ""
			if state.get_script():
				script_path = state.get_script().resource_path.to_lower()
			if "intro" in script_path or "final" in script_path:
				return true
	return false


func _aplicar_posicion_y_alineacion_personaje(nombre_personaje: String) -> void:
	var target_left: float = 16.0
	var target_right: float = -16.0
	var color_borde: Color = Color(0.88, 0.72, 0.28, 1.0)
	var color_nombre: Color = Color(1.0, 0.84, 0.31, 1.0)
	var alineacion_bbcode: String = ""

	if _es_dialogo_intro_o_final():
		match nombre_personaje:
			"Sinchi":
				target_left = 16.0
				target_right = -140.0
				color_borde = Color(0.35, 0.90, 0.50, 1.0)
				color_nombre = Color(0.40, 1.0, 0.55, 1.0)
				alineacion_bbcode = "left"
			"Inti":
				target_left = 78.0
				target_right = -78.0
				color_borde = Color(1.0, 0.85, 0.25, 1.0)
				color_nombre = Color(1.0, 0.90, 0.25, 1.0)
				alineacion_bbcode = "center"
			"Carlos":
				target_left = 140.0
				target_right = -16.0
				color_borde = Color(0.35, 0.80, 1.0, 1.0)
				color_nombre = Color(0.40, 0.85, 1.0, 1.0)
				alineacion_bbcode = "right"
			_:
				target_left = 16.0
				target_right = -16.0
	else:
		target_left = 16.0
		target_right = -16.0
		match nombre_personaje:
			"Carlos":
				color_nombre = Color(0.40, 0.85, 1.0, 1.0)
			"Sinchi":
				color_nombre = Color(0.40, 1.0, 0.55, 1.0)
			"Inti":
				color_nombre = Color(1.0, 0.90, 0.25, 1.0)
			_:
				color_nombre = Color(1.0, 0.84, 0.31, 1.0)

	character_label.visible = not nombre_personaje.is_empty()
	character_label.add_theme_color_override("default_color", color_nombre)
	var nombre_traducido: String = tr(nombre_personaje, "dialogue")
	if not alineacion_bbcode.is_empty():
		character_label.text = "[%s]%s[/%s]" % [alineacion_bbcode, nombre_traducido, alineacion_bbcode]
	else:
		character_label.text = nombre_traducido

	# Animar posicion de la caja hacia el lado del personaje
	if margin_container:
		if _tween_pos and _tween_pos.is_valid():
			_tween_pos.kill()
		_tween_pos = create_tween().set_parallel(true)
		_tween_pos.tween_property(margin_container, "offset_left", target_left, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		_tween_pos.tween_property(margin_container, "offset_right", target_right, 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Borde del panel coloreado dinamicamente segun el personaje
	if panel_container:
		var style: StyleBoxFlat = panel_container.get_theme_stylebox(&"panel")
		if style:
			var nuevo_style: StyleBoxFlat = style.duplicate() as StyleBoxFlat
			nuevo_style.border_color = color_borde
			panel_container.add_theme_stylebox_override(&"panel", nuevo_style)

	# Aplicar alineacion al texto del dialogo en Intro y Final
	if not alineacion_bbcode.is_empty() and not dialogue_line.text.is_empty():
		if not dialogue_line.text.begins_with("[right]") and not dialogue_line.text.begins_with("[center]") and not dialogue_line.text.begins_with("[left]"):
			dialogue_line.text = "[%s]%s[/%s]" % [alineacion_bbcode, dialogue_line.text, alineacion_bbcode]


## Apply any changes to the balloon given a new [DialogueLine].
func apply_dialogue_line() -> void:
	mutation_cooldown.stop()

	progress.hide()
	is_waiting_for_input = false
	balloon.focus_mode = Control.FOCUS_ALL
	balloon.grab_focus()

	# Duck musica al 40% durante los dialogos
	_atenuar_musica()

	# Posicionar caja y alinear textos segun el personaje (Carlos derecha, Inti centro, Sinchi izquierda)
	_aplicar_posicion_y_alineacion_personaje(dialogue_line.character)

	# Cargar audio de voz de forma previa para que empiece exactamente junto con el texto
	var audio_stream: AudioStream = null
	if dialogue_line.has_tag("voice"):
		var voice_path: String = dialogue_line.get_tag_value("voice")
		audio_stream = _cargar_audio_voz(voice_path)

	# Preparar label sin caracteres visibles para evitar destellos
	dialogue_label.hide()
	dialogue_label.dialogue_line = dialogue_line
	dialogue_label.visible_characters = 0

	responses_menu.hide()
	responses_menu.responses = dialogue_line.responses

	# Mostrar balloon y label sincronizados
	balloon.show()
	will_hide_balloon = false
	dialogue_label.show()

	if audio_stream:
		audio_stream_player.stream = audio_stream
		
		# Volumen de voz: subirle volumen a Carlos (+2.5 dB adicional)
		if dialogue_line.character == "Carlos":
			audio_stream_player.volume_db = 2.5
		else:
			audio_stream_player.volume_db = 0.0

		# Calibrar la velocidad del texto para que avance al ritmo natural de la voz
		if not dialogue_line.text.is_empty():
			var num_chars: int = max(dialogue_line.text.length(), 1)
			var dur_audio: float = audio_stream.get_length()
			if dur_audio > 0.2:
				dialogue_label.seconds_per_step = clamp((dur_audio * 0.75) / float(num_chars), 0.015, 0.065)
			else:
				dialogue_label.seconds_per_step = 0.02
			dialogue_label.seconds_per_pause_step = 0.08
		
		# Disparo simultaneo exacto de audio y texto
		audio_stream_player.play()
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()

		# Esperar a que termine de reproducir la voz (BLOQUEADO: no se puede saltar mientras habla)
		if audio_stream_player.playing:
			await audio_stream_player.finished
		elif not dialogue_line.text.is_empty() and dialogue_label.is_typing:
			await dialogue_label.finished_typing

		# Notificar fin de habla para que los personajes pasen a animacion Idle
		if Engine.has_singleton("DialogueManager"):
			Engine.get_singleton("DialogueManager").waiting_for_input.emit()

		# Pausa natural antes de avanzar o permitir que el jugador avance
		is_waiting_for_input = true
		progress.show()
		var current_line_id: String = dialogue_line.next_id
		await get_tree().create_timer(0.8).timeout
		if is_instance_valid(dialogue_line) and dialogue_line.next_id == current_line_id and is_waiting_for_input:
			is_waiting_for_input = false
			next(current_line_id)
	else:
		audio_stream_player.volume_db = 0.0
		dialogue_label.seconds_per_step = 0.02
		dialogue_label.seconds_per_pause_step = 0.3
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			await dialogue_label.finished_typing

		# Wait for next line
		if dialogue_line.responses.size() > 0:
			balloon.focus_mode = Control.FOCUS_NONE
			responses_menu.show()
		elif dialogue_line.time != "":
			var time: float = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
			await get_tree().create_timer(time).timeout
			next(dialogue_line.next_id)
		else:
			is_waiting_for_input = true
			balloon.focus_mode = Control.FOCUS_ALL
			balloon.grab_focus()


## Go to the next line
func next(next_id: String) -> void:
	dialogue_line = await dialogue_resource.get_next_dialogue_line(next_id, temporary_game_states)


#region Signals


func _on_mutation_cooldown_timeout() -> void:
	if will_hide_balloon:
		will_hide_balloon = false
		balloon.hide()


func _on_mutated(mutation: Dictionary) -> void:
	if not mutation.is_inline:
		is_waiting_for_input = false
		will_hide_balloon = true
		mutation_cooldown.start(0.1)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# If voice is playing, DO NOT allow skipping or advancing the dialogue!
	if audio_stream_player and audio_stream_player.playing:
		get_viewport().set_input_as_handled()
		return

	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		is_waiting_for_input = false
		next(dialogue_line.next_id)
	elif (event.is_action_pressed(next_action) or event.is_action_pressed(&"jump")) and get_viewport().gui_get_focus_owner() == balloon:
		is_waiting_for_input = false
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)


#endregion
