extends Node

func _ready() -> void:
	await get_tree().process_frame
	await get_tree().process_frame
	await get_tree().process_frame
	
	var img = get_viewport().get_texture().get_image()
	if img:
		img.save_png("scratch/creditos_real_scene.png")
		print("REAL CRED Scene captured to scratch/creditos_real_scene.png")
	get_tree().quit(0)
