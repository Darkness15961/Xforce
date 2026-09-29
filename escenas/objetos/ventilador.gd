extends Area2D

@export var fuerzaEmpuje: float = -600.0
@export var permitirControlHorizontal: bool = true

var _cuerposEnArea: Array[Node2D] = []

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	process_physics_priority = 100

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Jugador") and body is CharacterBody2D:
		if not _cuerposEnArea.has(body):
			_cuerposEnArea.append(body)

func _on_body_exited(body: Node2D) -> void:
	_cuerposEnArea.erase(body)

func _physics_process(_delta: float) -> void:
	for body in _cuerposEnArea:
		if is_instance_valid(body) and body is CharacterBody2D:
			body.velocity.y = fuerzaEmpuje
