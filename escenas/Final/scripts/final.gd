extends CanvasLayer

## Cinematica final: Chakana completa con musica de fondo.

const ESCENA_CREDITOS := "res://escenas/ui/Creditos.tscn"
const MUSICA_FINAL := "res://assets/audio/02. EL CABALLERO HUECO GAMEJAM OST.mp3"
const SPEED_IDLE := 1.0
const SPEED_HABLAR := 1.15

@export_category("Configuracion de Personaje")
@export var carlos: AnimatedSprite2D
@export var sinchi: AnimatedSprite2D
@export var inti: AnimatedSprite2D
@export var tiempoEspera: float = 2.0

@export_category("Configuracion de Dialogo")
@export var recursoDialogo: DialogueResource
@export var tituloInicioDialogo: String = "ending"

@export_category("Configuracion de Audio")
@export var musica: AudioStream
@export var musicaDesde: float = 0.0

var _yendoACreditos: bool = false
var _posCarlos: Vector2 = Vector2.ZERO
var _posSinchi: Vector2 = Vector2.ZERO
var _reproductorMusica: AudioStreamPlayer

func _ready() -> void:
	Global.detener_musica_menu()
	Global.posicionAudio = 0.0

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
	_reproductorMusica.name = "MusicaFinal"
	_reproductorMusica.bus = &"Musica"
	var stream: AudioStream = musica if musica else load(MUSICA_FINAL) as AudioStream
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	_reproductorMusica.stream = stream
	add_child(_reproductorMusica)
	_reproductorMusica.play(musicaDesde)

func _detener_musica() -> void:
	if _reproductorMusica and is_instance_valid(_reproductorMusica):
		_reproductorMusica.stop()
		_reproductorMusica.queue_free()
		_reproductorMusica = null
	Global.posicionAudio = 0.0

func _exit_tree() -> void:
	_detener_musica()

#region Mutaciones del .dialogue

## Ambos aparecen mirandose: ya colaboraron y se reconocen.
func aparecer_protagonistas() -> void:
	if carlos:
		carlos.visible = true
		carlos.position = _posCarlos
		carlos.scale.x = -absf(carlos.scale.x)
		carlos.speed_scale = SPEED_IDLE
		_play_safe(carlos, "Idle")
	if sinchi:
		sinchi.visible = true
		sinchi.position = _posSinchi
		sinchi.scale.x = absf(sinchi.scale.x)
		sinchi.speed_scale = SPEED_IDLE
		_play_safe(sinchi, "Idle")

## Inti aparece en calma (Chakana completa).
func aparecer_inti() -> void:
	_mirarse_entre_ellos()
	if not inti:
		return
	inti.visible = true
	inti.modulate.a = 0.0
	inti.speed_scale = SPEED_IDLE
	_play_safe(inti, "idle")
	var tween := create_tween()
	tween.tween_property(inti, "modulate:a", 1.0, 0.8)
	await tween.finished

## Destello suave al activar la Chakana antes del adios final.
func activar_chakana() -> void:
	var fondo: ColorRect = get_node_or_null("ColorRect") as ColorRect
	if not fondo:
		return
	var colorBase: Color = fondo.color
	var tween := create_tween()
	tween.tween_property(fondo, "color", Color(1.0, 0.92, 0.55, 1.0), 0.45)
	tween.tween_property(fondo, "color", colorBase, 0.55)
	await tween.finished

#endregion

func _mirarse_entre_ellos() -> void:
	if carlos and carlos.visible:
		carlos.position = _posCarlos
		carlos.scale.x = -absf(carlos.scale.x)
	if sinchi and sinchi.visible:
		sinchi.position = _posSinchi
		sinchi.scale.x = absf(sinchi.scale.x)

func _on_got_dialogue(linea: DialogueLine) -> void:
	_set_hablando(linea.character)

func _set_hablando(nombre: String) -> void:
	_poner_en_idle()
	match nombre:
		"Carlos":
			if carlos and carlos.visible:
				carlos.speed_scale = SPEED_HABLAR
				_play_safe(carlos, "Idle")
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
		_play_safe(carlos, "Idle")
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
	_ir_a_creditos()

func _on_omitir_pressed() -> void:
	_ir_a_creditos()

func _ir_a_creditos() -> void:
	if _yendoACreditos:
		return
	_yendoACreditos = true
	_poner_en_idle()
	_detener_musica()
	get_tree().change_scene_to_file(ESCENA_CREDITOS)
