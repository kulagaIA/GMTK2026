extends Control


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_play_button_pressed() -> void:
	Game.reset_run()
	Game.start_game()

func _on_credits_button_pressed() -> void:
	push_warning("Credits are not yet implemented")

func _on_quit_button_pressed() -> void:
	Game.quit_to_desktop()

#region Settings

@export var settings_scene : PackedScene
var _settings_screen: Control

func _on_settings_button_pressed() -> void:
	_settings_screen = settings_scene.instantiate() as Control
	Game.canvas_manager.push_content_to_layer(JamUtils.layer_ui_menu, _settings_screen)

#endregion

#region HowTo

@export var how_to_scene : PackedScene
var _howto_screen: Control

func _on_tutorial_button_pressed() -> void:
	_howto_screen = how_to_scene.instantiate() as Control
	Game.canvas_manager.push_content_to_layer(JamUtils.layer_ui_menu, _howto_screen)

#endregion
