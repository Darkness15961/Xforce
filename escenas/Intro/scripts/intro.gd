extends CanvasLayer

@export_category("Configuración de Personaje")
@export var personaje: Node2D
@export var tiempo_espera: float = 2.0

@export_category("Configuración de Diálogo")
@export var dialogue_resource: DialogueResource
@export var dialogue_start_title: String = "start"


func _ready() -> void:
	# Asegura que el personaje esté oculto al inicio
	if personaje:
		personaje.visible = false
	
	iniciar_secuencia()


func iniciar_secuencia() -> void:
	# Espera los 2 segundos sin congelar el juego
	await get_tree().create_timer(tiempo_espera).timeout
	
	if personaje:
		personaje.visible = true
		# Invierte la escala en X para que mire a la izquierda
		personaje.scale.x = -abs(personaje.scale.x)
	
	# Escucha cuando finalize cualquier diálogo
	if not DialogueManager.dialogue_ended.is_connected(_on_dialogue_ended):
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
	
	# Muestra el diálogo asignado
	if dialogue_resource:
		DialogueManager.show_example_dialogue_balloon(dialogue_resource, dialogue_start_title)


func _on_dialogue_ended(_resource: DialogueResource) -> void:
	# Acción a realizar cuando el diálogo termine por completo
	pass
