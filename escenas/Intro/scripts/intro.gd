extends CanvasLayer

const NIVEL_1 := "res://escenas/niveles/nivel1-debug.tscn"
const SPEED_IDLE := 1.0
const SPEED_HABLAR := 1.15
const MIRAR_LENTO := 1.35
const MIRAR_NERVIOSO := 0.35
const NERVIOS_OFFSET := 8.0

@export_category("Configuración de Personaje")
@export var carlos: AnimatedSprite2D
@export var sinchi: AnimatedSprite2D
@export var inti: AnimatedSprite2D
@export var tiempo_espera: float = 2.0

@export_category("Configuración de Diálogo")
@export var dialogue_resource: DialogueResource
@export var dialogue_start_title: String = "start"

var _yendo_a_nivel: bool = false
var _pos_carlos: Vector2 = Vector2.ZERO
var _pos_sinchi: Vector2 = Vector2.ZERO
var _mirando_entorno: bool = false
var _nerviosos: bool = false
var _carlos_con_celular: bool = false
var _voltear_carlos: bool = false
var _voltear_sinchi: bool = false
var _tween_nervios_carlos: Tween
var _tween_nervios_sinchi: Tween


func _ready() -> void:
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
	aparecer_carlos()

	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	if not DialogueManager.got_dialogue.is_connected(_on_got_dialogue):
		DialogueManager.got_dialogue.connect(_on_got_dialogue)
	if not DialogueManager.waiting_for_input.is_connected(_detener_habla):
		DialogueManager.waiting_for_input.connect(_detener_habla)

	if dialogue_resource:
		DialogueManager.show_dialogue_balloon(dialogue_resource, dialogue_start_title, [self])


#region Mutaciones del .dialogue

func aparecer_carlos() -> void:
	if not carlos:
		return
	_carlos_con_celular = false
	carlos.visible = true
	carlos.position = _pos_carlos
	carlos.scale.x = -abs(carlos.scale.x)
	carlos.speed_scale = SPEED_IDLE
	_play_safe(carlos, "Idle")


func sacar_celular() -> void:
	if not carlos:
		return
	_carlos_con_celular = true
	carlos.speed_scale = SPEED_IDLE
	_play_safe(carlos, "celular_apagado")
	# Con el celular mira el entorno volteando
	_voltear_carlos = true
	_iniciar_voltear(carlos, true)


func guardar_celular() -> void:
	if not carlos:
		return
	_voltear_carlos = false
	_carlos_con_celular = false
	carlos.speed_scale = SPEED_IDLE
	_play_safe(carlos, "Idle")
	carlos.position = _pos_carlos
	carlos.scale.x = -abs(carlos.scale.x)


func aparecer_sinchi() -> void:
	if not sinchi:
		return
	sinchi.visible = true
	sinchi.position = _pos_sinchi
	sinchi.scale.x = abs(sinchi.scale.x)
	sinchi.speed_scale = SPEED_IDLE
	_play_safe(sinchi, "Idle")
	# Sinchi mira de derecha a izquierda; Carlos aún no la fija
	_voltear_sinchi = true
	_iniciar_voltear(sinchi, false)


## Carlos se queda mirando a Sinchi (fijo) mientras ella sigue volteando.
func carlos_mira_a_sinchi() -> void:
	_voltear_carlos = false
	if carlos:
		carlos.position = _pos_carlos
		carlos.scale.x = -abs(carlos.scale.x)


## Ambos se miran fijamente y dejan de voltear.
func mirarse_fijamente() -> void:
	_voltear_carlos = false
	_voltear_sinchi = false
	_mirando_entorno = false
	_mirarse_entre_ellos()


func aparecer_inti() -> void:
	_voltear_carlos = false
	_voltear_sinchi = false
	_mirando_entorno = false
	_ponerse_nerviosos()
	if not inti:
		return
	inti.visible = true
	inti.modulate.a = 0.0
	inti.speed_scale = SPEED_IDLE
	_play_safe(inti, "idle")
	var tween := create_tween()
	tween.tween_property(inti, "modulate:a", 1.0, 0.6)

#endregion


func _anim_carlos() -> StringName:
	return &"celular_apagado" if _carlos_con_celular else &"Idle"


func _iniciar_voltear(sprite: AnimatedSprite2D, es_carlos: bool) -> void:
	_mirando_entorno = true
	_bucle_voltear(sprite, es_carlos)


func _bucle_voltear(sprite: AnimatedSprite2D, es_carlos: bool) -> void:
	var activo: bool = _voltear_carlos if es_carlos else _voltear_sinchi
	if not activo or not _mirando_entorno or not is_instance_valid(sprite) or not sprite.visible:
		return
	sprite.scale.x = -sprite.scale.x
	await get_tree().create_timer(MIRAR_LENTO).timeout
	activo = _voltear_carlos if es_carlos else _voltear_sinchi
	if not activo or not _mirando_entorno or not is_instance_valid(sprite):
		return
	_bucle_voltear(sprite, es_carlos)


func _mirarse_entre_ellos() -> void:
	if carlos and carlos.visible:
		carlos.position = _pos_carlos
		carlos.scale.x = -abs(carlos.scale.x)
	if sinchi and sinchi.visible:
		sinchi.position = _pos_sinchi
		sinchi.scale.x = abs(sinchi.scale.x)


## Al aparecer Inti: vaivén rápido izquierda/derecha (nerviosos).
func _ponerse_nerviosos() -> void:
	_nerviosos = true
	_mirarse_entre_ellos()
	if _tween_nervios_carlos:
		_tween_nervios_carlos.kill()
		_tween_nervios_carlos = null
	if _tween_nervios_sinchi:
		_tween_nervios_sinchi.kill()
		_tween_nervios_sinchi = null
	if carlos and carlos.visible:
		_tween_nervios_carlos = _crear_vaiven_nervioso(carlos, _pos_carlos)
	if sinchi and sinchi.visible:
		_tween_nervios_sinchi = _crear_vaiven_nervioso(sinchi, _pos_sinchi)


func _crear_vaiven_nervioso(sprite: AnimatedSprite2D, base: Vector2) -> Tween:
	var escala_abs: float = absf(sprite.scale.x)
	var tween := create_tween()
	tween.set_loops()
	# Mira a la derecha mientras se mueve a la derecha
	tween.tween_callback(func() -> void: sprite.scale.x = escala_abs)
	tween.tween_property(sprite, "position:x", base.x + NERVIOS_OFFSET, MIRAR_NERVIOSO).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	# Mira a la izquierda mientras se mueve a la izquierda
	tween.tween_callback(func() -> void: sprite.scale.x = -escala_abs)
	tween.tween_property(sprite, "position:x", base.x - NERVIOS_OFFSET, MIRAR_NERVIOSO).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	return tween


func _detener_nervios() -> void:
	_nerviosos = false
	if _tween_nervios_carlos:
		_tween_nervios_carlos.kill()
		_tween_nervios_carlos = null
	if _tween_nervios_sinchi:
		_tween_nervios_sinchi.kill()
		_tween_nervios_sinchi = null
	if carlos:
		carlos.position = _pos_carlos
	if sinchi:
		sinchi.position = _pos_sinchi


func _on_got_dialogue(line: DialogueLine) -> void:
	_set_hablando(line.character)


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
	if _yendo_a_nivel:
		return
	_yendo_a_nivel = true
	_voltear_carlos = false
	_voltear_sinchi = false
	_mirando_entorno = false
	_detener_nervios()
	_poner_en_idle()
	get_tree().change_scene_to_file(NIVEL_1)
