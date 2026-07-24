class_name FaceRenderer
extends SubViewport

const HEAD_PITCH_MULTIPLIER := 0.6
const HEAD_YAW_MULTIPLIER := 0.4
const MAX_HEAD_PITCH := deg_to_rad(60)
const MAX_HEAD_YAW := deg_to_rad(45)
const HEAD_POSITION_INTERPOLATION_SPEED := 8.0
const HEAD_LEAN_VERTICAL_OFFSET := 0.05
const HEAD_LEAN_FORWARD_OFFSET := -0.15

@onready var head: MeshInstance3D = %HeadPlaceholder

var _head_rest_position: Vector3
var _target_position: Vector3

func _ready() -> void:
	_head_rest_position = head.position

func _process(delta: float) -> void:
	head.position = head.position.lerp(_target_position, delta * HEAD_POSITION_INTERPOLATION_SPEED)

func set_head_color(color: Color) -> void:
	var material := head.get_active_material(0).duplicate()
	material.albedo_color = color
	head.set_surface_override_material(0, material)

func set_head_rotation(pitch: float, yaw: float) -> void:
	var head_pitch : float = clamp(
		pitch * HEAD_PITCH_MULTIPLIER,
		-MAX_HEAD_PITCH,
		MAX_HEAD_PITCH
		)
	var head_yaw : float = clamp(
		yaw * HEAD_YAW_MULTIPLIER,
		-MAX_HEAD_YAW,
		MAX_HEAD_YAW
		)
	head.rotation.x = -head_pitch
	head.rotation.y = head_yaw
	
	var lean := head_pitch / MAX_HEAD_PITCH
	_target_position = _head_rest_position + Vector3(
		0.0,
		lean * HEAD_LEAN_VERTICAL_OFFSET,
		lean * HEAD_LEAN_FORWARD_OFFSET
		)
