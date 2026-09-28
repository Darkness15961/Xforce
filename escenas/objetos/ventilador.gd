extends Area2D
## Ventilador.gd
## Colocar en un nodo Area2D con un CollisionShape2D hijo.
## Empuja hacia arriba a cualquier cuerpo del grupo "Jugador" mientras
## permanezca dentro del area, de forma constante (el ventilador siempre
## esta "encendido", no necesita activarse con un input).

@export var fuerzaEmpuje: float = -600.0   # negativo = hacia arriba (Y crece hacia abajo en 2D)
@export var permitirControlHorizontal: bool = true  # si el jugador puede moverse en X mientras sube

#region Alias de compatibilidad
var fuerza_empuje: float:
	get: return fuerzaEmpuje
	set(val): fuerzaEmpuje = val

var permitir_control_horizontal: bool:
	get: return permitirControlHorizontal
	set(val): permitirControlHorizontal = val
#endregion

var _cuerposEnArea: Array[Node2D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	# IMPORTANTE: hacemos que este nodo procese su _physics_process
	# DESPUES que el jugador, para poder sobrescribir su velocity.y
	# (si tu Player tiene prioridad distinta, ajusta este numero)
	process_physics_priority = 100

	# Debug: confirma que el nodo arranco bien y muestra su configuracion real
	print("Ventilador listo. Monitoring=", monitoring, " | Collision Mask=", collision_mask)

func _on_body_entered(body: Node2D) -> void:
	# Debug: esto debe imprimirse SIEMPRE que algo (cualquier cosa) entre al area,
	# sin importar si es el jugador o no. Si nunca aparece esta linea, el problema
	# es 100% de colision (Mask/Shape/posicion), no del script.
	print("Algo entro al area: ", body.name, " | grupos: ", body.get_groups())

	if body.is_in_group("Jugador") and body is CharacterBody2D:
		if not _cuerposEnArea.has(body):
			_cuerposEnArea.append(body)
			print("-> Es el jugador, empezando a empujar hacia arriba")

func _on_body_exited(body: Node2D) -> void:
	_cuerposEnArea.erase(body)

func _physics_process(_delta: float) -> void:
	for body in _cuerposEnArea:
		if not is_instance_valid(body):
			_cuerposEnArea.erase(body)
			continue

		# Sobrescribimos la velocidad vertical: esto anula la gravedad
		# que el propio script del jugador haya aplicado este frame.
		body.velocity.y = fuerzaEmpuje

		# El movimiento horizontal (velocity.x) no lo tocamos, asi que
		# el jugador puede seguir moviendose a los lados mientras sube.
