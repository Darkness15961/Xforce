extends Control

@onready var btnVolver: Button = $MarginContainer/VBoxPrincipal/BtnVolver

func _ready() -> void:
	Global.reproducir_musica_menu()
	if btnVolver:
		btnVolver.grab_focus()

	_inicializar_botones_redes()

func _inicializar_botones_redes() -> void:
	# Terry Brayan Chauca Rolando
	_conectar_red(
		"MarginContainer/VBoxPrincipal/GridMiembros/CardTerry/Margin/VBox/HBoxRedes/BtnInstagram",
		"https://www.instagram.com/https_terryyy?stkn=MWpzbW1leDhkeG5iMA==",
		"Instagram: @https_terryyy",
		"MarginContainer/VBoxPrincipal/GridMiembros/CardTerry/Margin/VBox/HBoxRedes/LabelInfo"
	)
	_conectar_red(
		"MarginContainer/VBoxPrincipal/GridMiembros/CardTerry/Margin/VBox/HBoxRedes/BtnLinkedIn",
		"https://www.linkedin.com/in/terry-brayan-chauca-rolando-7b47a533b",
		"LinkedIn: Terry Chauca",
		"MarginContainer/VBoxPrincipal/GridMiembros/CardTerry/Margin/VBox/HBoxRedes/LabelInfo"
	)

	# Patrick Gabriel Chauca Ramos
	_conectar_red(
		"MarginContainer/VBoxPrincipal/GridMiembros/CardPatrick/Margin/VBox/HBoxRedes/BtnInstagram",
		"https://www.instagram.com/elgvbi?stkn=MWhnbTh2d2xycGtvag==a",
		"Instagram: @elgvbi",
		"MarginContainer/VBoxPrincipal/GridMiembros/CardPatrick/Margin/VBox/HBoxRedes/LabelInfo"
	)
	_conectar_red(
		"MarginContainer/VBoxPrincipal/GridMiembros/CardPatrick/Margin/VBox/HBoxRedes/BtnYouTube",
		"https://youtube.com/@elgvbi?si=BkVSOtplHPE5UwXb",
		"YouTube: @elgvbi",
		"MarginContainer/VBoxPrincipal/GridMiembros/CardPatrick/Margin/VBox/HBoxRedes/LabelInfo"
	)

	# Carlos Eduardo Loaiza Martinez
	_conectar_red(
		"MarginContainer/VBoxPrincipal/GridMiembros/CardCarlos/Margin/VBox/HBoxRedes/BtnInstagram",
		"https://www.instagram.com/carlos_loaiza.005/",
		"Instagram: @carlos_loaiza.005",
		"MarginContainer/VBoxPrincipal/GridMiembros/CardCarlos/Margin/VBox/HBoxRedes/LabelInfo"
	)
	_conectar_red(
		"MarginContainer/VBoxPrincipal/GridMiembros/CardCarlos/Margin/VBox/HBoxRedes/BtnLinkedIn",
		"https://www.linkedin.com/in/carlos-eduardo-loaiza-martinez-1374602b0",
		"LinkedIn: Carlos Loaiza",
		"MarginContainer/VBoxPrincipal/GridMiembros/CardCarlos/Margin/VBox/HBoxRedes/LabelInfo"
	)
	_conectar_red(
		"MarginContainer/VBoxPrincipal/GridMiembros/CardCarlos/Margin/VBox/HBoxRedes/BtnGitHub",
		"https://github.com/ProgramCarlos234",
		"GitHub: @ProgramCarlos234",
		"MarginContainer/VBoxPrincipal/GridMiembros/CardCarlos/Margin/VBox/HBoxRedes/LabelInfo"
	)

	# Zoran Joshua Verastegui Alvarado
	_conectar_red(
		"MarginContainer/VBoxPrincipal/GridMiembros/CardZoran/Margin/VBox/HBoxRedes/BtnInstagram",
		"https://www.instagram.com/zoran_alvarado?stkn=dnI1bm85Y3N3NnU4",
		"Instagram: @zoran_alvarado",
		"MarginContainer/VBoxPrincipal/GridMiembros/CardZoran/Margin/VBox/HBoxRedes/LabelInfo"
	)
	_conectar_red(
		"MarginContainer/VBoxPrincipal/GridMiembros/CardZoran/Margin/VBox/HBoxRedes/BtnLinkedIn",
		"https://www.linkedin.com/in/zoran-alvarado-0a8285406/?isSelfProfile=true",
		"LinkedIn: Zoran Alvarado",
		"MarginContainer/VBoxPrincipal/GridMiembros/CardZoran/Margin/VBox/HBoxRedes/LabelInfo"
	)
	_conectar_red(
		"MarginContainer/VBoxPrincipal/GridMiembros/CardZoran/Margin/VBox/HBoxRedes/BtnTwitch",
		"https://www.twitch.tv/loc0zor",
		"Twitch: @loc0zor",
		"MarginContainer/VBoxPrincipal/GridMiembros/CardZoran/Margin/VBox/HBoxRedes/LabelInfo"
	)

	# Eduardo Ñaupa Yapura
	_conectar_red(
		"MarginContainer/VBoxPrincipal/GridMiembros/CardEduardo/Margin/VBox/HBoxRedes/BtnInstagram",
		"https://www.instagram.com/edu.yn6/",
		"Instagram: @edu.yn6",
		"MarginContainer/VBoxPrincipal/GridMiembros/CardEduardo/Margin/VBox/HBoxRedes/LabelInfo"
	)
	_conectar_red(
		"MarginContainer/VBoxPrincipal/GridMiembros/CardEduardo/Margin/VBox/HBoxRedes/BtnLinkedIn",
		"https://www.linkedin.com/in/eduardo-%C3%B1aupa-yapura-a08285346/",
		"LinkedIn: Eduardo Ñaupa",
		"MarginContainer/VBoxPrincipal/GridMiembros/CardEduardo/Margin/VBox/HBoxRedes/LabelInfo"
	)
	_conectar_red(
		"MarginContainer/VBoxPrincipal/GridMiembros/CardEduardo/Margin/VBox/HBoxRedes/BtnYouTube",
		"https://www.youtube.com/@eduardonaupayapura7418",
		"YouTube: @eduardonaupayapura7418",
		"MarginContainer/VBoxPrincipal/GridMiembros/CardEduardo/Margin/VBox/HBoxRedes/LabelInfo"
	)

func _conectar_red(rutaBoton: String, url: String, textoHover: String, rutaLabel: String) -> void:
	var btn: Button = get_node_or_null(rutaBoton)
	var lbl: Label = get_node_or_null(rutaLabel)
	if not btn:
		return

	btn.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	btn.pressed.connect(func(): OS.shell_open(url))

	if lbl:
		btn.mouse_entered.connect(func():
			lbl.text = textoHover
			lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4, 1.0))
		)
		btn.mouse_exited.connect(func():
			lbl.text = "Clic para visitar"
			lbl.add_theme_color_override("font_color", Color(0.5, 0.65, 0.78, 0.75))
		)
		btn.focus_entered.connect(func():
			lbl.text = textoHover
			lbl.add_theme_color_override("font_color", Color(1.0, 0.85, 0.4, 1.0))
		)
		btn.focus_exited.connect(func():
			lbl.text = "Clic para visitar"
			lbl.add_theme_color_override("font_color", Color(0.5, 0.65, 0.78, 0.75))
		)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("Pausa"):
		_volver_al_menu()

func _on_btn_volver_pressed() -> void:
	_volver_al_menu()

func _volver_al_menu() -> void:
	Global.cambiar_escena("res://escenas/ui/menu.tscn")
