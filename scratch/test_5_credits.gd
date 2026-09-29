@tool
extends SceneTree

func _init() -> void:
	var viewport = get_root()
	viewport.size = Vector2i(640, 360)
	var theme = load("res://default_theme.tres")
	
	# Layout A: 2 columns x 3 rows (5 members + 1 info/agradecimiento card)
	var creditos = Control.new()
	creditos.name = "CreditosA"
	creditos.set_anchors_preset(Control.PRESET_FULL_RECT)
	creditos.theme = theme
	
	# 1. Cielo
	var cielo = TextureRect.new()
	cielo.texture = load("res://assets/sprites/fondo_cielo.png")
	cielo.set_anchors_preset(Control.PRESET_FULL_RECT)
	cielo.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cielo.stretch_mode = TextureRect.STRETCH_SCALE
	creditos.add_child(cielo)
	
	# 2. Nubes fondo
	var nubes_back = TextureRect.new()
	nubes_back.texture = load("res://assets/sprites/nubes_fondo.png")
	nubes_back.set_anchors_preset(Control.PRESET_FULL_RECT)
	nubes_back.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	nubes_back.stretch_mode = TextureRect.STRETCH_SCALE
	creditos.add_child(nubes_back)
	
	# 3. Montana
	var montana = TextureRect.new()
	montana.texture = load("res://assets/sprites/fondo_montana.png")
	montana.set_anchors_preset(Control.PRESET_FULL_RECT)
	montana.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	montana.stretch_mode = TextureRect.STRETCH_SCALE
	creditos.add_child(montana)
	
	# 4. Nubes frente
	var nubes_front = TextureRect.new()
	nubes_front.texture = load("res://assets/sprites/nubes_frente.png")
	nubes_front.set_anchors_preset(Control.PRESET_FULL_RECT)
	nubes_front.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	nubes_front.stretch_mode = TextureRect.STRETCH_SCALE
	creditos.add_child(nubes_front)
	
	# 5. Casas
	var casas = TextureRect.new()
	casas.texture = load("res://assets/sprites/fondo_casas.png")
	casas.set_anchors_preset(Control.PRESET_FULL_RECT)
	casas.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	casas.stretch_mode = TextureRect.STRETCH_SCALE
	creditos.add_child(casas)
	
	# 6. Cerca
	var cerca = TextureRect.new()
	cerca.texture = load("res://assets/sprites/fondo_cerca.png")
	cerca.set_anchors_preset(Control.PRESET_FULL_RECT)
	cerca.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	cerca.stretch_mode = TextureRect.STRETCH_SCALE
	creditos.add_child(cerca)
	
	# 7. Oscurecedor
	var oscurecedor = ColorRect.new()
	oscurecedor.color = Color(0.04, 0.05, 0.09, 0.65)
	oscurecedor.set_anchors_preset(Control.PRESET_FULL_RECT)
	creditos.add_child(oscurecedor)
	
	var margin = MarginContainer.new()
	margin.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 14)
	margin.add_theme_constant_override("margin_right", 14)
	margin.add_theme_constant_override("margin_top", 8)
	margin.add_theme_constant_override("margin_bottom", 6)
	creditos.add_child(margin)
	
	var vbox = VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 3)
	margin.add_child(vbox)
	
	var v_header = VBoxContainer.new()
	v_header.add_theme_constant_override("separation", 1)
	vbox.add_child(v_header)
	
	var titulo = Label.new()
	titulo.text = "CREDITOS"
	titulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	titulo.add_theme_color_override("font_color", Color(1, 0.85, 0.3, 1))
	titulo.add_theme_font_size_override("font_size", 12)
	v_header.add_child(titulo)
	
	var subtitulo = Label.new()
	subtitulo.text = "— CHAKANA —"
	subtitulo.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitulo.add_theme_color_override("font_color", Color(0.65, 0.85, 1.0, 1))
	subtitulo.add_theme_font_size_override("font_size", 8)
	v_header.add_child(subtitulo)
	
	var sep1 = HSeparator.new()
	vbox.add_child(sep1)
	
	var grid = GridContainer.new()
	grid.columns = 2
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 6)
	vbox.add_child(grid)
	
	var style_card = StyleBoxFlat.new()
	style_card.bg_color = Color(0.07, 0.09, 0.14, 0.85)
	style_card.border_color = Color(0.24, 0.36, 0.52, 0.6)
	style_card.set_border_width_all(1)
	style_card.set_corner_radius_all(4)
	
	var style_btn_norm = StyleBoxFlat.new()
	style_btn_norm.bg_color = Color(0.12, 0.16, 0.24, 0.85)
	style_btn_norm.border_color = Color(0.28, 0.4, 0.58, 0.5)
	style_btn_norm.set_border_width_all(1)
	style_btn_norm.set_corner_radius_all(3)
	
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
				{"tex": tex_li, "name": "LinkedIn", "user": "Terry Chauca"}
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
				{"tex": tex_li, "name": "LinkedIn", "user": "Carlos Loaiza"},
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
		},
		{
			"nombre": "Eduardo Ñaupa Yapura",
			"alias": "Dark",
			"rol": "Diseñador 2D / Programador",
			"redes": [
				{"tex": tex_ig, "name": "Instagram", "user": "@edu.yn6"},
				{"tex": tex_li, "name": "LinkedIn", "user": "Eduardo Ñaupa"},
				{"tex": tex_yt, "name": "YouTube", "user": "@eduardonaupayapura7418"}
			]
		},
		{
			"is_info": true,
			"titulo": "GAMEJAM PATRIMONIO 2026",
			"sub": "Chakana",
			"detalle": "Juego desarrollado para participar en la GameJam Patrimonio 2026.",
			"gracias": "¡Muchas gracias por jugar!"
		}
	]
	
	for m in members:
		var panel = PanelContainer.new()
		panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
		panel.add_theme_stylebox_override("panel", style_card)
		grid.add_child(panel)
		
		var card_margin = MarginContainer.new()
		card_margin.add_theme_constant_override("margin_left", 10)
		card_margin.add_theme_constant_override("margin_right", 10)
		card_margin.add_theme_constant_override("margin_top", 5)
		card_margin.add_theme_constant_override("margin_bottom", 5)
		panel.add_child(card_margin)
		
		var card_vbox = VBoxContainer.new()
		card_vbox.add_theme_constant_override("separation", 2)
		card_margin.add_child(card_vbox)
		
		if m.has("is_info"):
			var lbl_t = Label.new()
			lbl_t.text = m["titulo"]
			lbl_t.add_theme_color_override("font_color", Color(1, 0.86, 0.35, 1))
			lbl_t.add_theme_font_size_override("font_size", 9)
			card_vbox.add_child(lbl_t)
			
			var lbl_s = Label.new()
			lbl_s.text = m["sub"]
			lbl_s.add_theme_color_override("font_color", Color(0.55, 0.85, 1, 1))
			lbl_s.add_theme_font_size_override("font_size", 8)
			card_vbox.add_child(lbl_s)
			
			var lbl_d = Label.new()
			lbl_d.text = m["detalle"]
			lbl_d.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
			lbl_d.add_theme_color_override("font_color", Color(0.82, 0.86, 0.9, 0.9))
			lbl_d.add_theme_font_size_override("font_size", 7)
			card_vbox.add_child(lbl_d)
			
			var lbl_g = Label.new()
			lbl_g.text = m.get("gracias", "")
			lbl_g.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4, 0.9))
			lbl_g.add_theme_font_size_override("font_size", 7)
			card_vbox.add_child(lbl_g)
			continue
		
		var lbl_nom = Label.new()
		lbl_nom.text = m["nombre"]
		lbl_nom.add_theme_color_override("font_color", Color(1, 0.86, 0.35, 1))
		lbl_nom.add_theme_font_size_override("font_size", 9)
		card_vbox.add_child(lbl_nom)
		
		var hbox_sub = HBoxContainer.new()
		hbox_sub.add_theme_constant_override("separation", 4)
		card_vbox.add_child(hbox_sub)
		
		var lbl_alias = Label.new()
		lbl_alias.text = m["alias"]
		lbl_alias.add_theme_color_override("font_color", Color(0.55, 0.85, 1.0, 1))
		lbl_alias.add_theme_font_size_override("font_size", 7)
		hbox_sub.add_child(lbl_alias)
		
		var lbl_dot = Label.new()
		lbl_dot.text = "•"
		lbl_dot.add_theme_color_override("font_color", Color(0.4, 0.5, 0.6, 1))
		lbl_dot.add_theme_font_size_override("font_size", 7)
		hbox_sub.add_child(lbl_dot)
		
		var lbl_rol = Label.new()
		lbl_rol.text = m["rol"]
		lbl_rol.add_theme_color_override("font_color", Color(0.82, 0.86, 0.9, 1))
		lbl_rol.add_theme_font_size_override("font_size", 7)
		hbox_sub.add_child(lbl_rol)
		
		var hbox_redes = HBoxContainer.new()
		hbox_redes.add_theme_constant_override("separation", 6)
		hbox_redes.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		card_vbox.add_child(hbox_redes)
		
		for r in m["redes"]:
			var btn = Button.new()
			btn.custom_minimum_size = Vector2(22, 22)
			btn.icon = r["tex"]
			btn.expand_icon = true
			btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
			btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_CENTER
			btn.add_theme_stylebox_override("normal", style_btn_norm)
			btn.tooltip_text = r["name"] + ": " + r["user"]
			hbox_redes.add_child(btn)
			
		var lbl_info = Label.new()
		lbl_info.text = "Clic para visitar"
		lbl_info.add_theme_color_override("font_color", Color(0.5, 0.65, 0.78, 0.75))
		lbl_info.add_theme_font_size_override("font_size", 7)
		lbl_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		lbl_info.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		hbox_redes.add_child(lbl_info)
	
	var sep2 = HSeparator.new()
	vbox.add_child(sep2)
	
	var btn_volver = Button.new()
	btn_volver.text = "VOLVER AL MENU"
	btn_volver.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	btn_volver.flat = true
	btn_volver.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	btn_volver.add_theme_font_size_override("font_size", 9)
	vbox.add_child(btn_volver)
	
	viewport.add_child(creditos)
	
	for i in range(10):
		await process_frame
		
	var img = viewport.get_texture().get_image()
	if img:
		img.save_png("scratch/credits_5_preview.png")
		print("SUCCESS: 5-member layout saved to scratch/credits_5_preview.png")
	
	quit(0)
