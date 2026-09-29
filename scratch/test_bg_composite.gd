@tool
extends SceneTree

func _init() -> void:
	var viewport = get_root()
	viewport.size = Vector2i(640, 360)
	
	var root = Control.new()
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	
	# 1. Cielo
	var cielo = TextureRect.new()
	cielo.texture = load("res://assets/sprites/fondo_cielo.png")
	cielo.set_anchors_preset(Control.PRESET_FULL_RECT)
	cielo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cielo.stretch_mode = TextureRect.STRETCH_SCALE
	root.add_child(cielo)
	
	# 2. Nubes fondo
	var nubes_back = TextureRect.new()
	nubes_back.texture = load("res://assets/sprites/nubes_fondo.png")
	nubes_back.set_anchors_preset(Control.PRESET_FULL_RECT)
	nubes_back.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	nubes_back.stretch_mode = TextureRect.STRETCH_SCALE
	root.add_child(nubes_back)
	
	# 3. Montana
	var montana = TextureRect.new()
	montana.texture = load("res://assets/sprites/fondo_montana.png")
	montana.set_anchors_preset(Control.PRESET_FULL_RECT)
	montana.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	montana.stretch_mode = TextureRect.STRETCH_SCALE
	root.add_child(montana)
	
	# 4. Nubes frente
	var nubes_front = TextureRect.new()
	nubes_front.texture = load("res://assets/sprites/nubes_frente.png")
	nubes_front.set_anchors_preset(Control.PRESET_FULL_RECT)
	nubes_front.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	nubes_front.stretch_mode = TextureRect.STRETCH_SCALE
	root.add_child(nubes_front)
	
	# 5. Casas
	var casas = TextureRect.new()
	casas.texture = load("res://assets/sprites/fondo_casas.png")
	casas.set_anchors_preset(Control.PRESET_FULL_RECT)
	casas.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	casas.stretch_mode = TextureRect.STRETCH_SCALE
	root.add_child(casas)
	
	# 6. Cerca
	var cerca = TextureRect.new()
	cerca.texture = load("res://assets/sprites/fondo_cerca.png")
	cerca.set_anchors_preset(Control.PRESET_FULL_RECT)
	cerca.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cerca.stretch_mode = TextureRect.STRETCH_SCALE
	root.add_child(cerca)
	
	viewport.add_child(root)
	
	for i in range(10):
		await process_frame
		
	var img = viewport.get_texture().get_image()
	if img:
		img.save_png("scratch/test_bg_composite.png")
		print("SUCCESS: Background composite saved to scratch/test_bg_composite.png")
		
	quit(0)
