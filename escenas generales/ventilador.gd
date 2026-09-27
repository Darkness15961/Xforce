extends Area2D
## Ventilador.gd
## Colocar en un nodo Area2D con un CollisionShape2D hijo.
## Empuja hacia arriba a cualquier cuerpo del grupo "Jugador" mientras
## permanezca dentro del área, de forma constante (el ventilador siempre
## está "encendido", no necesita activarse con un input).

@export var fuerza_empuje: float = -600.0   # negativo = hacia arriba (Y crece hacia abajo en 2D)
@export var permitir_control_horizontal: bool = true  # si el jugador puede moverse en X mientras sube

var _cuerpos_en_area: Array[Node2D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# IMPORTANTE: hacemos que este nodo procese su _physics_process
	# DESPUÉS que el jugador, para poder sobrescribir su velocity.y
	# (si tu Player tiene prioridad distinta, ajusta este número)
	process_physics_priority = 100

	# Debug: confirma que el nodo arrancó bien y muestra su configuración real
	print("Ventilador listo. Monitoring=", monitoring, " | Collision Mask=", collision_mask)

func _on_body_entered(body: Node2D) -> void:
	# Debug: esto debe imprimirse SIEMPRE que algo (cualquier cosa) entre al área,
	# sin importar si es el jugador o no. Si nunca aparece esta línea, el problema
	# es 100% de colisión (Mask/Shape/posición), no del script.
	print("Algo entró al área: ", body.name, " | grupos: ", body.get_groups())

	if body.is_in_group("Jugador") and body is CharacterBody2D:
		if not _cuerpos_en_area.has(body):
			_cuerpos_en_area.append(body)
			print("-> Es el jugador, empezando a empujar hacia arriba")

func _on_body_exited(body: Node2D) -> void:
	_cuerpos_en_area.erase(body)

func _physics_process(_delta: float) -> void:
	for body in _cuerpos_en_area:
		if not is_instance_valid(body):
			_cuerpos_en_area.erase(body)
			continue

		# Sobrescribimos la velocidad vertical: esto anula la gravedad
		# que el propio script del jugador haya aplicado este frame.
		body.velocity.y = fuerza_empuje

		# El movimiento horizontal (velocity.x) no lo tocamos, así que
		# el jugador puede seguir moviéndose a los lados mientras sube.
