extends SceneTree

func _init() -> void:
	# Add Global autoload manually
	var global_script = load("res://globales/Global.gd")
	var global_node = Node.new()
	global_node.name = "Global"
	global_node.set_script(global_script)
	get_root().add_child(global_node)
	
	var cred_scene = load("res://escenas/ui/Creditos.tscn").instantiate()
	get_root().add_child(cred_scene)
	
	for i in range(15):
		await process_frame
		
	var img = get_root().get_texture().get_image()
	if img:
		img.save_png("scratch/creditos_real_scene.png")
		print("SUCCESS: Real scene captured to scratch/creditos_real_scene.png")
		
	quit(0)
