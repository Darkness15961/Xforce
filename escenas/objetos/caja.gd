extends RigidBody2D

var sfx_impacto: AudioStreamPlayer2D = null
var tiempo_ultimo_impacto: float = 0.0

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)
	
	sfx_impacto = AudioStreamPlayer2D.new()
	sfx_impacto.name = "SFXCosasCayendo"
	sfx_impacto.stream = load("res://assets/audio/SFX_COSAS CAYENDO.mp3")
	sfx_impacto.bus = &"SFX"
	add_child(sfx_impacto)

func _physics_process(delta: float) -> void:
	tiempo_ultimo_impacto += delta

func _on_body_entered(_body: Node) -> void:
	if tiempo_ultimo_impacto > 0.25 and abs(linear_velocity.y) > 35.0:
		tiempo_ultimo_impacto = 0.0
		if sfx_impacto:
			sfx_impacto.play()
