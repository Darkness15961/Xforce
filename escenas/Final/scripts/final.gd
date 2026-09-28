extends CanvasLayer

## Cinemática final: Chakana completa. Tono calmado, sin música de fondo.

const ESCENA_CREDITOS := "res://escenas/ui/Creditos.tscn"
const SPEED_IDLE := 1.0
const SPEED_HABLAR := 1.15

@export_category("Configuración de Personaje")
@export var carlos: AnimatedSprite2D
@export var sinchi: AnimatedSprite2D
@export var inti: AnimatedSprite2D
@export var tiempo_espera: float = 2.0

@export_category("Configuración de Diálogo")
@export var dialogue_resource: DialogueResource
@export var dialogue_start_title: String = "ending"

var _yendo_a_creditos: bool = false
var _pos_carlos: Vector2 = Vector2.ZERO
var _pos_sinchi: Vector2 = Vector2.ZERO


func _ready() -> void:
	Global.detener_musica_menu()
	Global.posicionAudio = 0.0

	if carlos:
		_pos_carlos = carlos.position
		carlos.visible = false
		carlos.speed_scale = SPEED_IDLE
		_play_safe(carlos, "Idle")
	if sinchi:
		_pos_sinchi = sinchi.position
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
	await get_tree().create_timer(tiempo_espera).timeout

	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	if not DialogueManager.got_dialogue.is_connected(_on_got_dialogue):
		DialogueManager.got_dialogue.connect(_on_got_dialogue)
	if not DialogueManager.waiting_for_input.is_connected(_detener_habla):
		DialogueManager.waiting_for_input.connect(_detener_habla)

	if dialogue_resource:
		DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start_title, [self])


#region Mutaciones del .dialogue

## Ambos aparecen mirándose: ya colaboraron y se reconocen.
func aparecer_protagonistas() -> void:
	if carlos:
		carlos.visible = true
		carlos.position = _pos_carlos
		carlos.scale.x = -absf(carlos.scale.x)
		carlos.speed_scale = SPEED_IDLE
		_play_safe(carlos, "Idle")
	if sinchi:
		sinchi.visible = true
		sinchi.position = _pos_sinchi
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


## Destello suave al activar la Chakana antes del adiós final.
func activar_chakana() -> void:
	var fondo: ColorRect = get_node_or_null("ColorRect") as ColorRect
	if not fondo:
		return
	var color_base: Color = fondo.color
	var tween := create_tween()
	tween.tween_property(fondo, "color", Color(1.0, 0.92, 0.55, 1.0), 0.45)
	tween.tween_property(fondo, "color", color_base, 0.55)
	await tween.finished

#endregion


func _mirarse_entre_ellos() -> void:
	if carlos and carlos.visible:
		carlos.position = _pos_carlos
		carlos.scale.x = -absf(carlos.scale.x)
	if sinchi and sinchi.visible:
		sinchi.position = _pos_sinchi
		sinchi.scale.x = absf(sinchi.scale.x)


func _on_got_dialogue(line: DialogueLine) -> void:
	_set_hablando(line.character)


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
	if _yendo_a_creditos:
		return
	_yendo_a_creditos = true
	_poner_en_idle()
	get_tree().change_scene_to_file(ESCENA_CREDITOS)
