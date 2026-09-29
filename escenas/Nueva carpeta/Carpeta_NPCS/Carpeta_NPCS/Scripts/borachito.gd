extends CharacterBody2D

var puedeInteractuar: bool = false
var estaDistraido: bool = false
var yaHabloEnEstaVisita: bool = false
var mostrandoDialogo: bool = false

@export var jugador: CharacterBody2D
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D
@onready var burbujaDialogo: Control = get_node_or_null("BurbujaDialogo")
@onready var etiquetaTexto: Label = get_node_or_null("BurbujaDialogo/Texto")

func _ready() -> void:
	if not jugador:
		jugador = get_tree().get_first_node_in_group("Jugador") as CharacterBody2D
	anim.play("Distraido" if estaDistraido else "Idle")

func _process(_delta: float) -> void:
	if not jugador:
		jugador = get_tree().get_first_node_in_group("Jugador") as CharacterBody2D
	if jugador:
		anim.flip_h = jugador.global_position.x < global_position.x
	
	if puedeInteractuar and Input.is_action_just_pressed("Interact") and not mostrandoDialogo:
		if not estaDistraido and Global.itemChicha > 0:
			procesar_interaccion()

func procesar_interaccion() -> void:
	if estaDistraido:
		return
	
	if Global.itemChicha > 0:
		Global.consumir_chicha(1)
		estaDistraido = true
		anim.play("Distraido")
		collision_layer = 2
		if has_node("CollisionShape2D"):
			$CollisionShape2D.set_deferred("disabled", true)
		mostrar_mensaje_cabeza("¡Ay caracho, la chicha!\n¡Pasa nomas compadre!... ¡Hic!", 2.8)
	else:
		mostrar_mensaje_cabeza("¡Hic!... ¡No puedes pasar de aqui!\nConsigueme chicha... ¡Hic!", 2.5)

func mostrar_mensaje_cabeza(texto: String, duracion: float = 2.5) -> void:
	if not burbujaDialogo or not etiquetaTexto:
		return
	mostrandoDialogo = true
	Global.enDialogo = true
	etiquetaTexto.text = texto
	burbujaDialogo.visible = true
	
	await get_tree().create_timer(duracion).timeout
	if is_instance_valid(burbujaDialogo):
		burbujaDialogo.visible = false
	mostrandoDialogo = false
	Global.enDialogo = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		puedeInteractuar = true
		if not estaDistraido and not yaHabloEnEstaVisita and not mostrandoDialogo:
			yaHabloEnEstaVisita = true
			procesar_interaccion()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group("Jugador"):
		puedeInteractuar = false
		yaHabloEnEstaVisita = false

func _exit_tree() -> void:
	if mostrandoDialogo:
		Global.enDialogo = false
