extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	sensitivity_slider.value = Game.mouse_sensitivity_setting
	volume_slider.value = Game.sound_volume_setting
	_update_sensitivity_labels()
	_update_volume_labels()
	flip_x_button.set_pressed_no_signal(Game.flip_mouse_x)
	flip_y_button.set_pressed_no_signal(Game.flip_mouse_y)

func _on_back_button_pressed() -> void:
	Game.change_game_state(GameState.MENU)
	queue_free()

func _on_link_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))

@onready var flip_x_button: CheckButton = %FlipXButton
@onready var flip_y_button: CheckButton = %FlipYButton

@onready var sensitivity_slider: HSlider = %SensitivitySlider
@onready var min_sens_label: Label = %MinSensLabel
@onready var max_sens_label: Label = %MaxSensLabel
@onready var sensitivity_label: Label = %SensitivityLabel
const _sensitivity_label_format := "Mouse Sensitivity: %.1f"

@onready var volume_slider: HSlider = %VolumeSlider
@onready var min_volume_label: Label = %MinVolumeLabel
@onready var max_volume_label: Label = %MaxVolumeLabel
@onready var volume_label: Label = %VolumeLabel
const _volume_label_format := "Sound Volume: %.1f"

func _update_sensitivity_labels() -> void:
	const sens_label_format : String = "%.1f"
	min_sens_label.text = sens_label_format % [sensitivity_slider.min_value]
	max_sens_label.text = sens_label_format % [sensitivity_slider.max_value]

func _update_volume_labels() -> void:
	const volume_label_format : String = "%.1f"
	min_volume_label.text = volume_label_format % [volume_slider.min_value]
	max_volume_label.text = volume_label_format % [volume_slider.max_value]

func _on_sensitivity_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Game.mouse_sensitivity_setting = sensitivity_slider.value
		sensitivity_label.text = _sensitivity_label_format % [sensitivity_slider.value]

func _on_volume_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		Game.sound_volume_setting = volume_slider.value
		volume_label.text = _volume_label_format % [volume_slider.value]
		var bus_index := AudioServer.get_bus_index("Master")
		AudioServer.set_bus_volume_db(
			bus_index,
			linear_to_db(volume_slider.value)
		)

func _on_flip_x_button_toggled(toggled_on: bool) -> void:
	Game.flip_mouse_x = toggled_on

func _on_flip_y_button_toggled(toggled_on: bool) -> void:
	Game.flip_mouse_y = toggled_on
