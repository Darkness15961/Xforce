extends SceneTree

func _init() -> void:
	var viewport = get_root()
	viewport.size = Vector2i(640, 360)
	
	var scene = load("res://escenas/ui/Creditos.tscn").instantiate()
	viewport.add_child(scene)
	
	# Wait 2 frames to let layout calculate
	await process_frame
	await process_frame
	
	print("Creditos scene loaded successfully! Root size: ", scene.size)
	quit(0)
