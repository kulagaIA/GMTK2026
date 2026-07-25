class_name FaceRenderer
extends SubViewport


#region face movement constants

const HEAD_PITCH_MULTIPLIER := 0.6
const HEAD_YAW_MULTIPLIER := 0.4
const MAX_HEAD_PITCH := deg_to_rad(60)
const MAX_HEAD_YAW := deg_to_rad(45)
const HEAD_POSITION_INTERPOLATION_SPEED := 8.0
const HEAD_LEAN_VERTICAL_OFFSET := 0.05
const HEAD_LEAN_FORWARD_OFFSET := -0.40
#endregion

#region camera movement constants

const CAMERA_PITCH_MULTIPLIER := 0.2
const CAMERA_YAW_MULTIPLIER := 0.1
const CAMERA_POSITION_INTERPOLATION_SPEED := 6.0
const CAMERA_VERTICAL_OFFSET := 0.30
const CAMERA_DEPTH_OFFSET := -0.15

@export var camera_movement_enabled : bool = true
#endregion

@onready var head_pivot: Node3D = %HeadPivot
@onready var head_mesh: MeshInstance3D = %HeadMeshPlaceholder
@onready var hat_socket: Node3D = %HatSocket
@onready var camera: Camera3D = %Camera

var upgraded_hat := preload("res://Assets/Hats/UpgradedHat.tscn").instantiate() as Node3D

var _head_rest_position: Vector3
var _target_position: Vector3

var _camera_rest_position: Vector3
var _camera_target_position: Vector3
var _camera_rest_rotation: Vector3

func _ready() -> void:
	_head_rest_position = head_pivot.position
	_camera_rest_position = camera.position
	_camera_target_position = _camera_rest_position
	_camera_rest_rotation = camera.rotation
	init_hat()

func _process(delta: float) -> void:
	head_pivot.position = head_pivot.position.lerp(_target_position, delta * HEAD_POSITION_INTERPOLATION_SPEED)
	if camera_movement_enabled :
		camera.position = camera.position.lerp(
			_camera_target_position,
			delta * CAMERA_POSITION_INTERPOLATION_SPEED
			)

func set_head_color(color: Color) -> void:
	var material := head_mesh.get_active_material(0).duplicate()
	material.albedo_color = color
	head_mesh.set_surface_override_material(0, material)

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
	head_pivot.rotation.x = -head_pitch
	head_pivot.rotation.y = head_yaw
	var lean := head_pitch / MAX_HEAD_PITCH
	_target_position = _head_rest_position + Vector3(
		0.0,
		lean * HEAD_LEAN_VERTICAL_OFFSET,
		lean * HEAD_LEAN_FORWARD_OFFSET
		)
		
	camera.rotation = _camera_rest_rotation + Vector3(
		-head_pitch * CAMERA_PITCH_MULTIPLIER,
		head_yaw * CAMERA_YAW_MULTIPLIER,
		0.0
		)

	_camera_target_position = _camera_rest_position + Vector3(
		0.0,
		lean * CAMERA_VERTICAL_OFFSET,
		lean * CAMERA_DEPTH_OFFSET
		)

func set_hat(hat_node: Node3D) -> void:
	if hat_node == null:
		return
	for child in hat_socket.get_children():
		child.queue_free()
	var hat := hat_node.get_child(0) as MeshInstance3D
	hat.position.y = 0.33
	hat.scale.x = 0.6
	hat.scale.y = 0.6
	hat.scale.z = 0.6
	hat_socket.add_child(hat_node)

func init_hat() -> void:
	if Game.player_state.max_health.value > 100:
		set_hat(upgraded_hat)
