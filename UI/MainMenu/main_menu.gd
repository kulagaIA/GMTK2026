extends Control


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	sensitivity_slider.value = Game.mouse_sensitivity_setting
	_update_sensitivity_labels()
	flip_x_button.set_pressed_no_signal(Game.flip_mouse_x)
	flip_y_button.set_pressed_no_signal(Game.flip_mouse_y)

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

@onready var flip_x_button: CheckButton = %FlipXButton
@onready var flip_y_button: CheckButton = %FlipYButton

@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var min_sens_label: Label = %MinSensLabel
@onready var max_sens_label: Label = %MaxSensLabel
@onready var sensitivity_label: Label = %SensitivityLabel
const _sensitivity_label_format := "Mouse Sensitivity: %.1f"

func _update_sensitivity_labels() -> void:
	const sens_label_format : String = "%.1f"
	min_sens_label.text = sens_label_format % [sensitivity_slider.min_value]
	max_sens_label.text = sens_label_format % [sensitivity_slider.max_value]

func _on_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Game.mouse_sensitivity_setting = sensitivity_slider.value
		sensitivity_label.text = _sensitivity_label_format % [sensitivity_slider.value]

func _on_flip_x_button_toggled(toggled_on: bool) -> void:
	Game.flip_mouse_x = toggled_on

func _on_flip_y_button_toggled(toggled_on: bool) -> void:
	Game.flip_mouse_y = toggled_on

#endregion

#region HowTo

@export var how_to_scene : PackedScene
var _howto_screen: Control

func _on_tutorial_button_pressed() -> void:
	_howto_screen = how_to_scene.instantiate() as Control
	Game.canvas_manager.push_content_to_layer(JamUtils.layer_ui_menu, _howto_screen)

#endregion
