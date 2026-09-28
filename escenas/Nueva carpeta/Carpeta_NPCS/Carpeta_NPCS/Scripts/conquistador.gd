extends CharacterBody2D

var puedeInteractuar: bool = false
var estaDistraido: bool = false
var yaHabloEnEstaVisita: bool = false
var mostrandoDialogo: bool = false

@export var jugador: CharacterBody2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var burbujaDialogo: Control = get_node_or_null("BurbujaDialogo")
@onready var etiquetaTexto: Label = get_node_or_null("BurbujaDialogo/Texto")

var tweenDialogo: Tween = null

func _ready() -> void:
	if not jugador:
		jugador = get_tree().get_first_node_in_group("Jugador") as CharacterBody2D
	
	_asegurar_burbuja_dialogo()
	
	if estaDistraido:
		anim.play("Distraido")
		collision_layer = 2
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", true)
	else:
		anim.play("Idle")
		collision_layer = 1
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", false)

func _process(_delta: float) -> void:
	if not jugador:
		jugador = get_tree().get_first_node_in_group("Jugador") as CharacterBody2D
	
	if jugador:
		anim.flip_h = jugador.global_position.x < global_position.x
	
	# Si esta dentro y presiona interactuar, solo reacciona si trae el celular para entregarlo
	if puedeInteractuar and Input.is_action_just_pressed("Interact") and not mostrandoDialogo:
		if not estaDistraido and Global.itemCelular > 0:
			procesar_interaccion()

func procesar_interaccion() -> void:
	if estaDistraido:
		return
	
	if Global.itemCelular > 0:
		# Tiene celular: se distrae con el celular y abre el paso
		Global.consumir_celular(1)
		estaDistraido = true
		anim.play("Distraido")
		collision_layer = 2 # Deja de bloquear el paso del jugador
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", true)
		mostrar_mensaje_cabeza("¡Pardiez, que espejo magico!\n¡Pasad, forastero!", 2.8)
	else:
		# No tiene celular: dice el dialogo de bloqueo adaptado
		mostrar_mensaje_cabeza("¡Alto ahi! ¡Por la Corona,\nno podeis pasar de aqui!", 2.5)

func mostrar_mensaje_cabeza(texto: String, duracion: float = 2.5) -> void:
	_asegurar_burbuja_dialogo()
	if not burbujaDialogo or not etiquetaTexto:
		return
	
	mostrandoDialogo = true
	Global.enDialogo = true # Congela al personaje mientras habla
	
	etiquetaTexto.text = texto
	burbujaDialogo.visible = true
	burbujaDialogo.pivot_offset = burbujaDialogo.size / 2.0
	burbujaDialogo.scale = Vector2(0.5, 0.5)
	burbujaDialogo.modulate.a = 0.0
	
	if tweenDialogo and tweenDialogo.is_valid():
		tweenDialogo.kill()
	
	tweenDialogo = create_tween().set_parallel(true)
	tweenDialogo.tween_property(burbujaDialogo, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tweenDialogo.tween_property(burbujaDialogo, "modulate:a", 1.0, 0.15)
	
	await get_tree().create_timer(duracion).timeout
	
	var tweenSalida = create_tween().set_parallel(true)
	tweenSalida.tween_property(burbujaDialogo, "scale", Vector2(0.8, 0.8), 0.15)
	tweenSalida.tween_property(burbujaDialogo, "modulate:a", 0.0, 0.15)
	await tweenSalida.finished
	
	burbujaDialogo.visible = false
	mostrandoDialogo = false
	Global.enDialogo = false # El personaje ya se puede mover

func _asegurar_burbuja_dialogo() -> void:
	if burbujaDialogo and etiquetaTexto:
		return
	
	burbujaDialogo = get_node_or_null("BurbujaDialogo")
	if not burbujaDialogo:
		var panel = PanelContainer.new()
		panel.name = "BurbujaDialogo"
		panel.visible = false
		panel.z_index = 30
		panel.offset_left = -75.0
		panel.offset_top = -48.0
		panel.offset_right = 75.0
		panel.offset_bottom = -18.0
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var estilo = StyleBoxFlat.new()
		estilo.bg_color = Color(0.1, 0.09, 0.16, 0.92)
		estilo.border_color = Color(0.92, 0.77, 0.35, 1.0)
		estilo.border_width_left = 1
		estilo.border_width_top = 1
		estilo.border_width_right = 1
		estilo.border_width_bottom = 1
		estilo.corner_radius_top_left = 3
		estilo.corner_radius_top_right = 3
		estilo.corner_radius_bottom_right = 3
		estilo.corner_radius_bottom_left = 3
		estilo.content_margin_left = 6
		estilo.content_margin_top = 3
		estilo.content_margin_right = 6
		estilo.content_margin_bottom = 3
		panel.add_theme_stylebox_override("panel", estilo)
		
		var lbl = Label.new()
		lbl.name = "Texto"
		lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.custom_minimum_size = Vector2(138, 0)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		lbl.add_theme_color_override("font_outline_color", Color(0.08, 0.08, 0.12, 1))
		lbl.add_theme_constant_override("outline_size", 3)
		var fuente = load("res://assets/fuentes/Minecraft.ttf")
		if fuente:
			lbl.add_theme_font_override("font", fuente)
			lbl.add_theme_font_size_override("font_size", 9)
		
		panel.add_child(lbl)
		add_child(panel)
		burbujaDialogo = panel
		etiquetaTexto = lbl
	else:
		etiquetaTexto = burbujaDialogo.get_node_or_null("Texto")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		puedeInteractuar = true
		if estaDistraido:
			return
		
		# Solo se activa si el jugador NO ha hablado en esta visita a la zona
		if not yaHabloEnEstaVisita and not mostrandoDialogo:
			yaHabloEnEstaVisita = true
			procesar_interaccion()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		puedeInteractuar = false
		# Se valida explicitamente que el jugador haya salido de la zona para permitir hablar en la siguiente visita
		yaHabloEnEstaVisita = false

func _exit_tree() -> void:
	if mostrandoDialogo:
		Global.enDialogo = false
