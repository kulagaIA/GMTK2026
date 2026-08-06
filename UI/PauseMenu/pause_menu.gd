extends Control

# HACK: rework mouse mode management
var saved_mouse_mode : Input.MouseMode

func _enter_tree() -> void:
	saved_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Game.pause()

func _ready() -> void:
	pass

func _exit_tree() -> void:
	Game.unpause()

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		unpause()

func unpause() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()


func _on_resume_button_pressed() -> void:
	unpause()


func _on_title_button_pressed() -> void:
	Game.change_game_state(GameState.MENU)
	queue_free()


func _on_quit_button_pressed() -> void:
	Game.quit_to_desktop()
