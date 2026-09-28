extends Control

@onready var btnVolver: Button = $PanelFondo/MarginContainer/VBoxContainer/BtnVolver

func _ready() -> void:
	Global.reproducir_musica_menu()
	if btnVolver:
		btnVolver.grab_focus()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("Pausa"):
		_volver_al_menu()

func _on_btn_volver_pressed() -> void:
	_volver_al_menu()

func _volver_al_menu() -> void:
	Global.cambiar_escena("res://escenas/ui/menu.tscn")
