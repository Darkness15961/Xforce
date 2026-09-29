extends SceneTree

func _init() -> void:
	var viewport = get_root()
	viewport.size = Vector2i(640, 360)
	
	var scene = load("res://escenas/ui/Creditos.tscn").instantiate()
	viewport.add_child(scene)
	
	for i in range(10):
		await process_frame
	
	var img = viewport.get_texture().get_image()
	if img:
		img.save_png("scratch/test_capture.png")
		print("Screenshot saved to scratch/test_capture.png, size: ", img.get_size())
	else:
		print("No image texture found")
	quit(0)
