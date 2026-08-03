class_name WebHelperButton
extends Button

@export var capture_mouse_on_press : bool = false
@export var hide_in_web_build : bool = false

func _ready() -> void:
	if OS.has_feature("web"):
		if hide_in_web_build:
			visible = false

func _pressed() -> void:
	if OS.has_feature("web"):
		if hide_in_web_build:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
