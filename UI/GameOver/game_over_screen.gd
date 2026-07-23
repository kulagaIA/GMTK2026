extends Control

# HACK: rework mouse mode management
var saved_mouse_mode : Input.MouseMode

func _enter_tree() -> void:
	saved_mouse_mode = Input.mouse_mode
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Game.pause()

@onready var win_text: Label = %WinText
@onready var loose_text: Label = %LooseText

func _ready() -> void:
	win_text.visible = Game.stage_result == Game.StageResult.WIN
	loose_text.visible = Game.stage_result == Game.StageResult.LOOSE

func _exit_tree() -> void:
	Game.unpause()

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		unpause()

func unpause() -> void:
	Input.mouse_mode = saved_mouse_mode
	queue_free()


func _on_restart_button_pressed() -> void:
	Game.load_gameplay_scene()


func _on_title_button_pressed() -> void:
	Game.quit_to_title()


func _on_quit_button_pressed() -> void:
	Game.quit_to_desktop()


func _on_progression_pressed() -> void:
	Game.load_progression_scene()
	pass # Replace with function body.
