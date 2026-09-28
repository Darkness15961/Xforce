extends CharacterBody2D

var puede_interactuar: bool = false
var esta_distraido: bool = false
var ya_hablo_en_esta_visita: bool = false
var mostrando_dialogo: bool = false

@export var jugador: CharacterBody2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var burbuja_dialogo: Control = get_node_or_null("BurbujaDialogo")
@onready var texto_label: Label = get_node_or_null("BurbujaDialogo/Texto")

var tween_dialogo: Tween = null

func _ready() -> void:
	if not jugador:
		jugador = get_tree().get_first_node_in_group("Jugador") as CharacterBody2D
	
	_asegurar_burbuja_dialogo()
	
	if esta_distraido:
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
	
	# Si está dentro y presiona interactuar, solo reacciona si trae la chicha para entregarla
	if puede_interactuar and Input.is_action_just_pressed("Interact") and not mostrando_dialogo:
		if not esta_distraido and Global.Item_Chica > 0:
			procesar_interaccion()

func procesar_interaccion() -> void:
	if esta_distraido:
		return
	
	if Global.Item_Chica > 0:
		# Tiene chicha: se la bebe, se distrae y abre el paso
		Global.consumir_chicha(1)
		esta_distraido = true
		anim.play("Distraido")
		collision_layer = 2 # Deja de bloquear el paso del jugador
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", true)
		mostrar_mensaje_cabeza("¡Ay caracho, la chicha!\n¡Pasa nomás compadre!... ¡Hic!", 2.8)
	else:
		# No tiene chicha: dice el diálogo de bloqueo adaptado
		mostrar_mensaje_cabeza("¡Hic!... ¡No puedes pasar de aquí!\nConsígueme chicha... ¡Hic!", 2.5)

func mostrar_mensaje_cabeza(texto: String, duracion: float = 2.5) -> void:
	_asegurar_burbuja_dialogo()
	if not burbuja_dialogo or not texto_label:
		return
	
	mostrando_dialogo = true
	Global.en_dialogo = true # Congela al personaje mientras habla
	
	texto_label.text = texto
	burbuja_dialogo.visible = true
	burbuja_dialogo.pivot_offset = burbuja_dialogo.size / 2.0
	burbuja_dialogo.scale = Vector2(0.5, 0.5)
	burbuja_dialogo.modulate.a = 0.0
	
	if tween_dialogo and tween_dialogo.is_valid():
		tween_dialogo.kill()
	
	tween_dialogo = create_tween().set_parallel(true)
	tween_dialogo.tween_property(burbuja_dialogo, "scale", Vector2(1.0, 1.0), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween_dialogo.tween_property(burbuja_dialogo, "modulate:a", 1.0, 0.15)
	
	await get_tree().create_timer(duracion).timeout
	
	var tween_out = create_tween().set_parallel(true)
	tween_out.tween_property(burbuja_dialogo, "scale", Vector2(0.8, 0.8), 0.15)
	tween_out.tween_property(burbuja_dialogo, "modulate:a", 0.0, 0.15)
	await tween_out.finished
	
	burbuja_dialogo.visible = false
	mostrando_dialogo = false
	Global.en_dialogo = false # El personaje ya se puede mover

func _asegurar_burbuja_dialogo() -> void:
	if burbuja_dialogo and texto_label:
		return
	
	burbuja_dialogo = get_node_or_null("BurbujaDialogo")
	if not burbuja_dialogo:
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
		burbuja_dialogo = panel
		texto_label = lbl
	else:
		texto_label = burbuja_dialogo.get_node_or_null("Texto")

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		puede_interactuar = true
		if esta_distraido:
			return
		
		# Solo se activa si el jugador NO ha hablado en esta visita a la zona
		if not ya_hablo_en_esta_visita and not mostrando_dialogo:
			ya_hablo_en_esta_visita = true
			procesar_interaccion()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		puede_interactuar = false
		# Se valida explícitamente que el jugador haya salido de la zona para permitir hablar en la siguiente visita
		ya_hablo_en_esta_visita = false

func _exit_tree() -> void:
	if mostrando_dialogo:
		Global.en_dialogo = false
