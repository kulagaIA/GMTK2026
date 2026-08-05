class_name FaceRenderer
extends Node3D


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
@export var camera_distance := -1.4
@export var camera_height := 4.85
@export var camera_side := 0.0
@export var camera_follow_speed := 8.0
@export var shake_decay_speed := 4.0
#endregion

@onready var head_pivot: Node3D = %HeadPivot
@onready var head_mesh: Node3D = %HeadMesh
@onready var hat_socket: Node3D = %HatSocket
@onready var camera: Camera3D = %Camera
@onready var subviewport: SubViewport = %SubViewport

var _cached_actual_head : Node3D
func get_actual_head() -> Node3D:
	if not _cached_actual_head:
		# Shameless hardcode
		_cached_actual_head = head_mesh.get_node("Main_character/torso/neck/head") as Node3D
	return _cached_actual_head

func get_head_position() -> Vector3:
	return get_actual_head().global_position

var upgraded_hat := preload("res://Assets/Hats/UpgradedHat.tscn").instantiate() as Node3D

var _head_rest_position: Vector3
var _target_position: Vector3

var _camera_rest_position: Vector3
var _camera_target_position: Vector3
var _camera_rest_rotation: Vector3

var _current_shake := 0.0
var _shake_offset := Vector3.ZERO

func _ready() -> void:
	_head_rest_position = head_pivot.position
	_camera_rest_position = camera.position
	_camera_target_position = _camera_rest_position
	_camera_rest_rotation = camera.rotation
	init_hat()

func _process(delta: float) -> void:
	head_pivot.position = head_pivot.position.lerp(_target_position, delta * HEAD_POSITION_INTERPOLATION_SPEED)
	if camera_movement_enabled :
		var target = head_pivot.global_position + Vector3.DOWN * 0.08
		var desired_pos = target
		desired_pos += head_pivot.global_basis.y * camera_height
		desired_pos -= head_pivot.global_basis.z * camera_distance
		desired_pos += head_pivot.global_basis.x * camera_side
		_current_shake = move_toward(
			_current_shake,
			0.0,
			delta * shake_decay_speed
		)
		_shake_offset = _shake_offset.lerp(
			Vector3(
				randf_range(-1.0, 1.0),
				randf_range(-1.0, 1.0),
				randf_range(-1.0, 1.0)
			) * _current_shake,
			delta * 20.0
		)
		var shake_offset: Vector3 = Vector3(
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0),
			randf_range(-1.0, 1.0)
			) * _current_shake

		desired_pos += shake_offset
		camera.global_position = camera.global_position.lerp(
			desired_pos,
			delta * camera_follow_speed
		)
		camera.look_at(get_head_position(), Vector3.UP)
		#camera.rotate_object_local(Vector3.RIGHT, deg_to_rad(50))

func shake(strength: float) -> void:
	_current_shake = max(_current_shake, strength)

func set_head_color(color: Color) -> void:
	pass

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

var current_hat : Node3D = null

func spawn_hat_from_scene(hat_scene : PackedScene) -> void:
	if current_hat:
		current_hat.queue_free()
		current_hat = null
	if hat_scene:
		current_hat = hat_scene.instantiate() as Node3D
		hat_socket.add_child(current_hat)

func set_hat(hat_node: Node3D) -> void:
	for child in hat_socket.get_children():
		if child == current_hat: #hack for cases when we set the same hat multiple times, otherwise it will set the hat that is already queued for deletion
			return
		child.queue_free()
	current_hat = hat_node
	if hat_node == null:
		return
	var hat := hat_node.get_child(0) as MeshInstance3D
	hat.position.y = 0.15
	hat.scale.x = 0.4
	hat.scale.y = 0.4
	hat.scale.z = 0.4
	hat_socket.add_child(hat_node)

func init_hat() -> void:
	pass
	#if Game.player_state.max_health.value > 100:
		#set_hat(upgraded_hat)
