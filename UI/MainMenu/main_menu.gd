extends Control


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_play_button_pressed() -> void:
	Game.reset_run()
	Game.start_game()

func _on_quit_button_pressed() -> void:
	Game.quit_to_desktop()

#region Settings

func _on_settings_button_pressed() -> void:
	Game.change_game_state(GameState.SETTINGS)
	queue_free()

#endregion

#region Credits

func _on_credits_button_pressed() -> void:
	show_credits()

func show_credits() -> void:
	Game.change_game_state(GameState.CREDITS)
	queue_free()
	
#endregion

#region HowTo

@export var how_to_scene : PackedScene
var _howto_screen: Control

func _on_tutorial_button_pressed() -> void:
	_howto_screen = how_to_scene.instantiate() as Control
	Game.canvas_manager.push_content_to_layer(JamUtils.layer_ui_menu, _howto_screen)

#endregion
