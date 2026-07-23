class_name SmashPlayer
extends Node3D

@onready var camera_pivot: Node3D = %CameraPivot
@onready var camera: Camera3D = %Camera3D

signal hit

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _process(delta: float) -> void:
	pass

func _on_hit_occurred(attacker: Node, target: Node) -> void:
	pass

#region Input

var _last_mouse_direction: int = 0

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var direction: int = signi(event.relative.y)
		if direction == 0:
			return
		if direction == 1 and _last_mouse_direction == -1:
			hit.emit()
		_last_mouse_direction = direction

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Game.open_pause_menu()

#endregion
