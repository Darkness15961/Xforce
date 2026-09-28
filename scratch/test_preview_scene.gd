@tool
extends SceneTree

func _init() -> void:
	var viewport = get_root()
	viewport.size = Vector2i(640, 360)
	
	# Load default theme
	var theme = load("res://default_theme.tres")
	
	# Create test Creditos control
	var creditos = Control.new()
	creditos.name = "Creditos"
	creditos.set_anchors_preset(Control.PRESET_FULL_RECT)
	creditos.theme = theme
	
	# Background
	var cielo = TextureRect.new()
	cielo.texture = load("res://assets/sprites/fondo_cielo.png")
	cielo.set_anchors_preset(Control.PRESET_FULL_RECT)
	cielo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cielo.stretch_mode = TextureRect.STRETCH_SCALE
	creditos.add_child(cielo)
	
	var montana = TextureRect.new()
	montana.texture = load("res://assets/sprites/fondo_montana.png")
	montana.set_anchors_preset(Control.PRESET_BOTTOM_WIDE)
	montana.anchor_top = 0.35
	montana.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	montana.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	creditos.add_child(montana)
	
	var oscurecedor = ColorRect.new()
	oscurecedor.color = Color(0.04, 0.05, 0.09, 0.88)
	oscurecedor.set_anchors_preset(Control.PRESET_FULL_RECT)
	creditos.add_child(oscurecedor)
	
	# Main margin container
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 16)
	margin.add_theme_constant_override("margin_right", 16)
	margin.add_theme_constant_override("margin_top", 10)
	margin.add_theme_constant_override("margin_bottom", 8)
	creditos.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 5)
	margin.add_child(vbox)
	
	# Header
	var v_header = VBoxContainer.new()
	v_header.add_theme_constant_override("separation", 1)
	vbox.add_child(v_header)
	
	var titulo = Label.new()
	titulo.text = "CREDITOS"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.3, 1))
	titulo.add_theme_font_size_override("font_size", 13)
	v_header.add_child(titulo)
	
	var subtitulo = Label.new()
	subtitulo.text = "— WAYNA —"
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.add_theme_color_override("font_color", Color(0.65, 0.85, 1.0, 1))
	subtitulo.add_theme_font_size_override("font_size", 8)
	v_header.add_child(subtitulo)
	
	var sep1 = HSeparator.new()
	vbox.add_child(sep1)
	
	# Grid
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 10)
	grid.add_theme_constant_override("v_separation", 8)
	vbox.add_child(grid)
	
	# Styles for cards and buttons
	var style_card = StyleBoxFlat.new()
	style_card.bg_color = Color(0.07, 0.09, 0.14, 0.85)
	style_card.border_color = Color(0.24, 0.36, 0.52, 0.6)
	style_card.set_border_width_all(1)
	style_card.set_corner_radius_all(5)
	
	var style_btn_norm = StyleBoxFlat.new()
	style_btn_norm.bg_color = Color(0.12, 0.16, 0.24, 0.85)
	style_btn_norm.border_color = Color(0.28, 0.4, 0.58, 0.5)
	style_btn_norm.set_border_width_all(1)
	style_btn_norm.set_corner_radius_all(4)
	
	var tex_ig = load("res://assets/sprites/instagram_logo.png")
	var tex_li = load("res://assets/sprites/linkedin_logo.png")
	var tex_yt = load("res://assets/sprites/youtube_logo.png")
	var tex_gh = load("res://assets/sprites/github_logo.png")
	var tex_tw = load("res://assets/sprites/twitch_logo.png")
	
	var members = [
		{
			"nombre": "Terry Brayan Chauca Rolando",
			"alias": "TerryBCR",
			"rol": "Programador / Diseñador 2D",
			"redes": [
				{"tex": tex_ig, "name": "Instagram", "user": "@https_terryyy"},
				{"tex": tex_li, "name": "LinkedIn", "user": "Terry Brayan Chauca Rolando"}
			]
		},
		{
			"nombre": "Patrick Gabriel Chauca Ramos",
			"alias": "Gvbi",
			"rol": "Productor / Compositor musical",
			"redes": [
				{"tex": tex_ig, "name": "Instagram", "user": "@elgvbi"},
				{"tex": tex_yt, "name": "YouTube", "user": "@elgvbi"}
			]
		},
		{
			"nombre": "Carlos Eduardo Loaiza Martinez",
			"alias": "Carloncho",
			"rol": "Programador / Diseñador 2D / Doblaje",
			"redes": [
				{"tex": tex_ig, "name": "Instagram", "user": "@carlos_loaiza.005"},
				{"tex": tex_li, "name": "LinkedIn", "user": "Carlos Eduardo Loaiza Martinez"},
				{"tex": tex_gh, "name": "GitHub", "user": "@ProgramCarlos234"}
			]
		},
		{
			"nombre": "Zoran Joshua Verastegui Alvarado",
			"alias": "Locozor",
			"rol": "Programador / Doblaje",
			"redes": [
				{"tex": tex_ig, "name": "Instagram", "user": "@zoran_alvarado"},
				{"tex": tex_li, "name": "LinkedIn", "user": "Zoran Alvarado"},
				{"tex": tex_tw, "name": "Twitch", "user": "@loc0zor"}
			]
		}
	]
	
	for m in members:
		var panel = PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		panel.add_theme_stylebox_override("panel", style_card)
		grid.add_child(panel)
		
		var card_margin = MarginContainer.new()
		card_margin.add_theme_constant_override("margin_left", 12)
		card_margin.add_theme_constant_override("margin_right", 12)
		card_margin.add_theme_constant_override("margin_top", 8)
		card_margin.add_theme_constant_override("margin_bottom", 8)
		panel.add_child(card_margin)
		
		var card_vbox = VBoxContainer.new()
		card_vbox.add_theme_constant_override("separation", 4)
		card_margin.add_child(card_vbox)
		
		var lbl_nom = Label.new()
		lbl_nom.text = m["nombre"]
		lbl_nom.add_theme_color_override("font_color", Color(1, 0.86, 0.35, 1))
		lbl_nom.add_theme_font_size_override("font_size", 10)
		card_vbox.add_child(lbl_nom)
		
		var hbox_sub = HBoxContainer.new()
		hbox_sub.add_theme_constant_override("separation", 4)
		card_vbox.add_child(hbox_sub)
		
		var lbl_alias = Label.new()
		lbl_alias.text = m["alias"]
		lbl_alias.add_theme_color_override("font_color", Color(0.55, 0.85, 1.0, 1))
		lbl_alias.add_theme_font_size_override("font_size", 8)
		hbox_sub.add_child(lbl_alias)
		
		var lbl_dot = Label.new()
		lbl_dot.text = "•"
		lbl_dot.add_theme_color_override("font_color", Color(0.4, 0.5, 0.6, 1))
		lbl_dot.add_theme_font_size_override("font_size", 8)
		hbox_sub.add_child(lbl_dot)
		
		var lbl_rol = Label.new()
		lbl_rol.text = m["rol"]
		lbl_rol.add_theme_color_override("font_color", Color(0.82, 0.86, 0.9, 1))
		lbl_rol.add_theme_font_size_override("font_size", 8)
		hbox_sub.add_child(lbl_rol)
		
		var sep_c = HSeparator.new()
		card_vbox.add_child(sep_c)
		
		var spacer = Control.new()
		spacer.custom_minimum_size = Vector2(0, 2)
		card_vbox.add_child(spacer)
		
		var hbox_redes = HBoxContainer.new()
		hbox_redes.add_theme_constant_override("separation", 8)
		hbox_redes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		card_vbox.add_child(hbox_redes)
		
		for r in m["redes"]:
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(28, 28)
			btn.icon = r["tex"]
			btn.expand_icon = true
			btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
			btn.add_theme_stylebox_override("normal", style_btn_norm)
			btn.tooltip_text = r["name"] + ": " + r["user"]
			hbox_redes.add_child(btn)
			
		var lbl_info = Label.new()
		lbl_info.text = "Clic en logo para abrir perfil"
		lbl_info.add_theme_color_override("font_color", Color(0.5, 0.65, 0.78, 0.75))
		lbl_info.add_theme_font_size_override("font_size", 7)
		lbl_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox_redes.add_child(lbl_info)
	
	# Footer
	var sep2 = HSeparator.new()
	vbox.add_child(sep2)
	
	var btn_volver = Button.new()
	btn_volver.text = "VOLVER AL MENU"
	btn_volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_volver.flat = true
	btn_volver.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	btn_volver.add_theme_font_size_override("font_size", 10)
	vbox.add_child(btn_volver)
	
	viewport.add_child(creditos)
	
	for i in range(10):
		await process_frame
		
	var img = viewport.get_texture().get_image()
	if img:
		img.save_png("scratch/credits_preview.png")
		print("SUCCESS: Image saved to scratch/credits_preview.png")
	
	quit(0)
