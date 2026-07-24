class_name SmashPlayer
extends Node3D

var player_state: SmashPlayerState:
	get:
		return Game.player_state

signal hit(magnitude: float)

func _ready() -> void:
	assert(player_state)
	_show_hud()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	neck_position = max_neck_position
	neck_strike_amplitude = neck_position

func _exit_tree() -> void:
	_hide_hud()

func _process(delta: float) -> void:
	_consume_mouse_input(delta)
	_process_camera(delta)

func _on_hit_occurred(attacker: Node, target: Node) -> void:
	pass

#region HUD

@export var hud_scene : PackedScene
@onready var face_renderer := %FaceRenderer as FaceRenderer

func _show_hud() -> void:
	if hud_scene:
		var hud := hud_scene.instantiate() as Control
		var texture := face_renderer.get_texture()
		hud.set_face_texture(texture)
		Game.canvas_manager.set_layer_content(JamUtils.layer_ui_hud, hud)

func _hide_hud() -> void:
	Game.canvas_manager.clear_layer(JamUtils.layer_ui_hud)

#endregion

#region Input

func _input(event: InputEvent) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Game.open_pause_menu()
	
	# Mouse input
	_mouse_moving = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if _mouse_moving:
		var mouse_event = event as InputEventMouseMotion
		_input_yaw = (-1.0 if flip_mouse_x else 1.0) * mouse_event.relative.x * mouse_sensitivity
		_input_pitch = (1.0 if flip_mouse_y else -1.0) * mouse_event.relative.y * mouse_sensitivity


const MIN_TILT = deg_to_rad(-90)
const MAX_TILT = deg_to_rad(10)

const MIN_TURN = deg_to_rad(-20)
const MAX_TURN = deg_to_rad(20)

var _mouse_moving : bool = false
var _input_yaw : float
var _input_pitch : float

var flip_mouse_x : bool = false
var flip_mouse_y : bool = false

var _mouse_rotation : Vector3
var _player_rotation : Vector3

var mouse_sensitivity : float:
	get:
		return player_state.sensitivity.value

var min_neck_position : float = 0.0
@export var max_neck_position : float = 100.0
var neck_position : float = 0.0

var _neck_velocity : float = 0.0
var _neck_acceleration : float = 0.0
@export var neck_speed : float = 10.0
# WIP, do not use
var use_acceleration : bool = false
var neck_acceleration_rate : float = 1.0
var neck_deceleration_rate : float = .8

var neck_strike_amplitude : float = 0.0


func _consume_mouse_input(delta : float) -> void:
	_mouse_rotation.x += _input_pitch * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, MIN_TILT, MAX_TILT)
	_mouse_rotation.y += _input_yaw * delta
	_mouse_rotation.y += clamp(_mouse_rotation.y, MIN_TURN, MAX_TURN)
	
	if use_acceleration:
		_neck_acceleration = move_toward(_neck_acceleration, 0.0, neck_deceleration_rate * delta)
		_neck_acceleration += neck_acceleration_rate * _input_pitch
		_neck_velocity += _neck_acceleration * delta
	else:
		_neck_velocity = neck_speed * _input_pitch
	
	
	var neck_pos_unclamped := neck_position + _neck_velocity * delta
	neck_position = clamp(neck_pos_unclamped, min_neck_position, max_neck_position)
	if neck_position > neck_strike_amplitude:
		neck_strike_amplitude = neck_position
	#print("Input: %f, velocity: %f, position: %f, unclamped: %f" % [_input_pitch, _neck_velocity, neck_position, neck_pos_unclamped])
	if neck_position != neck_pos_unclamped:
		_neck_velocity = 0.0
		_neck_acceleration = 0.0
		if neck_pos_unclamped < min_neck_position and neck_strike_amplitude > 0.0:
			neck_strike_amplitude = 0.0
			hit.emit(_neck_velocity)
	
	if allow_turning:
		_player_rotation = Vector3(0, _mouse_rotation.y, 0)
	else:
		_player_rotation = Vector3.ZERO
	
	_camera_rotation = Vector3(_mouse_rotation.x, 0, 0)
	
	_input_pitch = 0
	_input_yaw = 0

#endregion

#region Camera

@onready var camera_pivot: Node3D = %CameraPivot
@onready var camera: Camera3D = %Camera3D

@export var allow_turning : bool = false

var _camera_rotation : Vector3

func _process_camera(delta : float) -> void:
	var tilt := remap(neck_position, min_neck_position, max_neck_position, MIN_TILT, MAX_TILT)
	
	_camera_rotation = Vector3(tilt, 0, 0)
	
	camera_pivot.transform.basis = Basis.from_euler(_camera_rotation)
	camera_pivot.rotation.z = 0
	
	global_transform.basis = Basis.from_euler(_player_rotation)

#endregion
