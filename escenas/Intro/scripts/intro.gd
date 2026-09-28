extends CanvasLayer

const NIVEL_1 := "res://escenas/niveles/nivel2-debug.tscn"
const MUSICA_INTRO := "res://assets/audio/02. EL CABALLERO HUECO GAMEJAM OST.mp3"
const MUSICA_DESDE := 57.7
const SPEED_IDLE := 1.0
const SPEED_HABLAR := 1.15
const MIRAR_LENTO := 1.35
const MIRAR_NERVIOSO := 0.35
const NERVIOS_OFFSET := 8.0

@export_category("Configuracion de Personaje")
@export var carlos: AnimatedSprite2D
@export var sinchi: AnimatedSprite2D
@export var inti: AnimatedSprite2D
@export var tiempoEspera: float = 2.0

@export_category("Configuracion de Dialogo")
@export var recursoDialogo: DialogueResource
@export var tituloInicioDialogo: String = "start"

#region Alias de compatibilidad
var tiempo_espera: float:
	get: return tiempoEspera
	set(val): tiempoEspera = val

var dialogue_resource: DialogueResource:
	get: return recursoDialogo
	set(val): recursoDialogo = val

var dialogue_start_title: String:
	get: return tituloInicioDialogo
	set(val): tituloInicioDialogo = val
#endregion

var _yendoANivel: bool = false
var _posCarlos: Vector2 = Vector2.ZERO
var _posSinchi: Vector2 = Vector2.ZERO
var _mirandoEntorno: bool = false
var _nerviosos: bool = false
var _carlosConCelular: bool = false
var _voltearCarlos: bool = false
var _voltearSinchi: bool = false
var _tweenNerviosCarlos: Tween
var _tweenNerviosSinchi: Tween
var _reproductorMusica: AudioStreamPlayer

func _ready() -> void:
	if carlos:
		_posCarlos = carlos.position
		carlos.visible = false
		carlos.speed_scale = SPEED_IDLE
		_play_safe(carlos, "Idle")
	if sinchi:
		_posSinchi = sinchi.position
		sinchi.visible = false
		sinchi.speed_scale = SPEED_IDLE
		_play_safe(sinchi, "Idle")
	if inti:
		inti.visible = false
		inti.speed_scale = SPEED_IDLE
		_play_safe(inti, "idle")

	var omitir: Button = get_node_or_null("Button") as Button
	if omitir and not omitir.pressed.is_connected(_on_omitir_pressed):
		omitir.pressed.connect(_on_omitir_pressed)

	iniciar_secuencia()

func iniciar_secuencia() -> void:
	_iniciar_musica()
	await get_tree().create_timer(tiempoEspera).timeout
	aparecer_carlos()

	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	if not DialogueManager.got_dialogue.is_connected(_on_got_dialogue):
		DialogueManager.got_dialogue.connect(_on_got_dialogue)
	if not DialogueManager.waiting_for_input.is_connected(_detener_habla):
		DialogueManager.waiting_for_input.connect(_detener_habla)

	if recursoDialogo:
		DialogueManager.show_dialogue_balloon(recursoDialogo, tituloInicioDialogo, [self])

func _iniciar_musica() -> void:
	if _reproductorMusica and is_instance_valid(_reproductorMusica):
		return
	Global.detener_musica_menu()
	_reproductorMusica = AudioStreamPlayer.new()
	_reproductorMusica.name = "MusicaIntro"
	_reproductorMusica.bus = &"Musica"
	var stream: AudioStream = load(MUSICA_INTRO) as AudioStream
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	_reproductorMusica.stream = stream
	add_child(_reproductorMusica)
	_reproductorMusica.play(MUSICA_DESDE)

func _detener_musica() -> void:
	if _reproductorMusica and is_instance_valid(_reproductorMusica):
		_reproductorMusica.stop()
		_reproductorMusica.queue_free()
		_reproductorMusica = null
	Global.posicionAudio = 0.0

#region Mutaciones del .dialogue

func aparecer_carlos() -> void:
	if not carlos:
		return
	_carlosConCelular = false
	carlos.visible = true
	carlos.position = _posCarlos
	carlos.scale.x = -abs(carlos.scale.x)
	carlos.speed_scale = SPEED_IDLE
	_play_safe(carlos, "Idle")

func sacar_celular() -> void:
	if not carlos:
		return
	_carlosConCelular = true
	carlos.speed_scale = SPEED_IDLE
	_play_safe(carlos, "celular_apagado")
	# Con el celular mira el entorno volteando
	_voltearCarlos = true
	_iniciar_voltear(carlos, true)

func guardar_celular() -> void:
	if not carlos:
		return
	_voltearCarlos = false
	_carlosConCelular = false
	carlos.speed_scale = SPEED_IDLE
	_play_safe(carlos, "Idle")
	carlos.position = _posCarlos
	carlos.scale.x = -abs(carlos.scale.x)

func aparecer_sinchi() -> void:
	if not sinchi:
		return
	sinchi.visible = true
	sinchi.position = _posSinchi
	sinchi.scale.x = abs(sinchi.scale.x)
	sinchi.speed_scale = SPEED_IDLE
	_play_safe(sinchi, "Idle")
	# Sinchi mira de derecha a izquierda; Carlos aun no la fija
	_voltearSinchi = true
	_iniciar_voltear(sinchi, false)

## Carlos se queda mirando a Sinchi (fijo) mientras ella sigue volteando.
func carlos_mira_a_sinchi() -> void:
	_voltearCarlos = false
	if carlos:
		carlos.position = _posCarlos
		carlos.scale.x = -abs(carlos.scale.x)

## Ambos se miran fijamente y dejan de voltear.
func mirarse_fijamente() -> void:
	_voltearCarlos = false
	_voltearSinchi = false
	_mirandoEntorno = false
	_mirarse_entre_ellos()

func aparecer_inti() -> void:
	_voltearCarlos = false
	_voltearSinchi = false
	_mirandoEntorno = false
	_ponerse_nerviosos()
	if not inti:
		return
	inti.visible = true
	inti.modulate.a = 0.0
	inti.speed_scale = SPEED_IDLE
	_play_safe(inti, "idle")
	var tween := create_tween()
	tween.tween_property(inti, "modulate:a", 1.0, 0.6)

## Dejan el miedo: se detienen y se miran fijamente para escuchar a Inti.
func calmarse() -> void:
	_detener_nervios()
	_mirarse_entre_ellos()

#endregion

func _anim_carlos() -> StringName:
	return &"celular_apagado" if _carlosConCelular else &"Idle"

func _iniciar_voltear(sprite: AnimatedSprite2D, es_carlos: bool) -> void:
	_mirandoEntorno = true
	_bucle_voltear(sprite, es_carlos)

func _bucle_voltear(sprite: AnimatedSprite2D, es_carlos: bool) -> void:
	var activo: bool = _voltearCarlos if es_carlos else _voltearSinchi
	if not activo or not _mirandoEntorno or not is_instance_valid(sprite) or not sprite.visible:
		return
	sprite.scale.x = -sprite.scale.x
	await get_tree().create_timer(MIRAR_LENTO).timeout
	activo = _voltearCarlos if es_carlos else _voltearSinchi
	if not activo or not _mirandoEntorno or not is_instance_valid(sprite):
		return
	_bucle_voltear(sprite, es_carlos)

func _mirarse_entre_ellos() -> void:
	if carlos and carlos.visible:
		carlos.position = _posCarlos
		carlos.scale.x = -abs(carlos.scale.x)
	if sinchi and sinchi.visible:
		sinchi.position = _posSinchi
		sinchi.scale.x = abs(sinchi.scale.x)

## Al aparecer Inti: vaiven rapido izquierda/derecha (nerviosos).
func _ponerse_nerviosos() -> void:
	_nerviosos = true
	_mirarse_entre_ellos()
	if _tweenNerviosCarlos:
		_tweenNerviosCarlos.kill()
		_tweenNerviosCarlos = null
	if _tweenNerviosSinchi:
		_tweenNerviosSinchi.kill()
		_tweenNerviosSinchi = null
	if carlos and carlos.visible:
		# Carlos empieza hacia la derecha
		_tweenNerviosCarlos = _crear_vaiven_nervioso(carlos, _posCarlos, false)
	if sinchi and sinchi.visible:
		# Sinchi en espejo: cuando Carlos va a la derecha, ella va a la izquierda
		_tweenNerviosSinchi = _crear_vaiven_nervioso(sinchi, _posSinchi, true)

func _crear_vaiven_nervioso(sprite: AnimatedSprite2D, base: Vector2, invertido: bool) -> Tween:
	var escalaAbs: float = absf(sprite.scale.x)
	var primerLado: float = -NERVIOS_OFFSET if invertido else NERVIOS_OFFSET
	var segundoLado: float = NERVIOS_OFFSET if invertido else -NERVIOS_OFFSET
	var tween := create_tween()
	tween.set_loops()
	# Mira hacia el lado al que se mueve
	tween.tween_callback(func() -> void: sprite.scale.x = signo_escala(primerLado, escalaAbs))
	tween.tween_property(sprite, "position:x", base.x + primerLado, MIRAR_NERVIOSO).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_callback(func() -> void: sprite.scale.x = signo_escala(segundoLado, escalaAbs))
	tween.tween_property(sprite, "position:x", base.x + segundoLado, MIRAR_NERVIOSO).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween

func signo_escala(direccion: float, escalaAbs: float) -> float:
	# Escala positiva = mira a la derecha; negativa = mira a la izquierda
	return escalaAbs if direccion > 0.0 else -escalaAbs

func _detener_nervios() -> void:
	_nerviosos = false
	if _tweenNerviosCarlos:
		_tweenNerviosCarlos.kill()
		_tweenNerviosCarlos = null
	if _tweenNerviosSinchi:
		_tweenNerviosSinchi.kill()
		_tweenNerviosSinchi = null
	if carlos:
		carlos.position = _posCarlos
	if sinchi:
		sinchi.position = _posSinchi

func _on_got_dialogue(linea: DialogueLine) -> void:
	_set_hablando(linea.character)

func _set_hablando(nombre: String) -> void:
	_poner_en_idle()
	match nombre:
		"Carlos":
			if carlos and carlos.visible:
				carlos.speed_scale = SPEED_HABLAR
				_play_safe(carlos, _anim_carlos())
		"Sinchi":
			if sinchi and sinchi.visible:
				sinchi.speed_scale = SPEED_HABLAR
				_play_safe(sinchi, "Idle")
		"Inti":
			if inti and inti.visible:
				inti.speed_scale = SPEED_HABLAR
				_play_safe(inti, "hablar")

func _detener_habla() -> void:
	_poner_en_idle()

func _poner_en_idle() -> void:
	if carlos and carlos.visible:
		carlos.speed_scale = SPEED_IDLE
		_play_safe(carlos, _anim_carlos())
	if sinchi and sinchi.visible:
		sinchi.speed_scale = SPEED_IDLE
		_play_safe(sinchi, "Idle")
	if inti and inti.visible:
		inti.speed_scale = SPEED_IDLE
		_play_safe(inti, "idle")

func _play_safe(sprite: AnimatedSprite2D, anim: StringName) -> void:
	if not sprite.sprite_frames:
		return
	if sprite.sprite_frames.has_animation(anim):
		if sprite.animation != anim or not sprite.is_playing():
			sprite.play(anim)

func _on_dialogue_ended(_resource: DialogueResource) -> void:
	_ir_a_nivel_1()

func _on_omitir_pressed() -> void:
	_ir_a_nivel_1()

func _ir_a_nivel_1() -> void:
	if _yendoANivel:
		return
	_yendoANivel = true
	_voltearCarlos = false
	_voltearSinchi = false
	_mirandoEntorno = false
	_detener_nervios()
	_poner_en_idle()
	_detener_musica()
	get_tree().change_scene_to_file(NIVEL_1)
