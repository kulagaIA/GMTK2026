class_name SmashPlayer
extends Node3D

var player_state: SmashPlayerState:
	get:
		return Game.player_state

signal hit(velocity: float, amplitude: float)
signal stun_status_changed(stunned: bool)

func _ready() -> void:
	Game.player = self
	assert(player_state)
	#player_state.health.value_changed.connect(_on_health_value_changed)
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	neck_position = starting_neck_position
	neck_strike_amplitude = neck_position

var _gameplay_started : bool = false

func handle_gameplay_started() -> void:
	update_hat()
	_gameplay_started = true
	last_shake_direction = 0

func handle_gameplay_ended() -> void:
	_reset_neck(0.7)
	unstun()
	_gameplay_started = false

func _exit_tree() -> void:
	pass

func _process(delta: float) -> void:
	_consume_mouse_input(delta)
	_process_camera(delta)

func _on_hit_occurred(info: HitInfo) -> void:
	face_renderer.shake(1.4)
	pass

#region HUD

@onready var face_renderer := %FaceRenderer as FaceRenderer

#endregion

#region Input

func _input(event: InputEvent) -> void:
	if _gameplay_started and Input.is_action_just_pressed("pivo"):
		if player_state.pivo_charges.value >= 1 and not _drinking_pivo and not stunned and Game.game_state_machine.current_state.name == "Gameplay":
			if player_state.pivo.is_available():
				_start_drinking_pivo()
				Game.tutorial_manager.dismiss_tutorial(Tutorial.Tag.BEER)
				#print("pivo charges left %d" % [player_state.pivo_charges.value])
		else:
			#print("out of pivo")
			pass
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause") and _gameplay_started:
		Game.open_pause_menu()
	if event.is_action_pressed("interact"):
		stun()
	
	# Mouse input
	_mouse_moving = event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
	if _mouse_moving and not _drinking_pivo:
		var mouse_event = event as InputEventMouseMotion
		if stunned or allow_turning:
			_input_yaw = (-1.0 if flip_mouse_x else 1.0) * mouse_event.relative.x * mouse_sensitivity * horizontal_sensitivity_multiplier
		if not stunned:
			_input_pitch = (1.0 if flip_mouse_y else -1.0) * mouse_event.relative.y * mouse_sensitivity * vertical_sensitivity_multiplier

const MIN_TILT = deg_to_rad(-80)
const MAX_TILT = deg_to_rad(40)

const MIN_TURN = deg_to_rad(-20)
const MAX_TURN = deg_to_rad(20)
var shake_threshold : float = deg_to_rad(15.0) 
var last_shake_direction : int = 0 

const MAX_SWING_SPEED = 1500.0

var _mouse_moving : bool = false
var _input_yaw : float
var _input_pitch : float

var flip_mouse_x : bool = true
var flip_mouse_y : bool = true
@export var vertical_sensitivity_multiplier : float = 1.0
@export var horizontal_sensitivity_multiplier : float = 0.2

var _mouse_rotation : Vector3
var _player_rotation : Vector3

var mouse_sensitivity : float:
	get:
		return Game.mouse_sensitivity_setting

var min_neck_position : float = 0.0
@export var max_neck_position : float = 100.0
var neck_position : float = 0.0

var neck_strike_amplitude : float = 0.0
@export var min_strike_amplitude : float = 20.0
var max_strike_amplitude : float:
	get: 
		return max_neck_position

var starting_neck_position : float:
	get:
		return remap(0.0, MAX_TILT, MIN_TILT, max_neck_position, min_neck_position)
var neck_rise_progress : float:
	get:
		return remap(neck_position, min_neck_position, max_neck_position, 0.0, 1.0)
var neck_tilt : float:
	get:
		return remap(neck_position, min_neck_position, max_neck_position, MIN_TILT, MAX_TILT)
var neck_turn : float:
	get:
		return _mouse_rotation.y

var _neck_velocity : float = 0.0
var _neck_acceleration : float = 0.0
var _neck_peak_velocity := 0.0
@export var neck_speed : float = 10.0
@export var neck_fall_sensitivity : Curve
@export var neck_rise_sensitivity : Curve

func get_sensitivity_curve(direction : float) -> Curve:
	if direction > 0:
		return neck_rise_sensitivity
	else:
		return neck_fall_sensitivity

func _consume_mouse_input(delta : float) -> void:
	_mouse_rotation.x += _input_pitch * delta
	_mouse_rotation.x = clamp(_mouse_rotation.x, MIN_TILT, MAX_TILT)
	_mouse_rotation.y += _input_yaw * delta
	_mouse_rotation.y = clamp(_mouse_rotation.y, MIN_TURN, MAX_TURN)
	
	var sensitivity_curve := get_sensitivity_curve(_input_pitch)
	_neck_velocity = neck_speed * _input_pitch * sensitivity_curve.sample_baked(neck_rise_progress) + _kickback_acceleration
	if _neck_velocity < 0.0:
		_neck_peak_velocity = max(_neck_peak_velocity, -_neck_velocity)
	
	var neck_pos_unclamped := neck_position + _neck_velocity * delta
	neck_position = clamp(neck_pos_unclamped, min_neck_position, max_neck_position)
	if neck_position > neck_strike_amplitude:
		neck_strike_amplitude = neck_position
	if neck_position != neck_pos_unclamped:
		if neck_pos_unclamped < min_neck_position and neck_strike_amplitude > min_strike_amplitude:
			hit.emit(
				clamp(_neck_peak_velocity / MAX_SWING_SPEED, 0.0, 1.0),
				clamp(neck_strike_amplitude / max_neck_position, 0.0, 1.0)
				)
			neck_strike_amplitude = 0.0
			_neck_peak_velocity = 0.0
			_add_kickback()
		_neck_velocity = 0.0
		_neck_acceleration = 0.0
	
	
	if allow_turning:
		_player_rotation = Vector3(0, neck_turn, 0)
		if abs(neck_turn) > shake_threshold and sign(neck_turn) != last_shake_direction:
			last_shake_direction = sign(neck_turn)
			shake_head()
	else:
		_player_rotation = Vector3.ZERO
	
	_camera_rotation = Vector3(_mouse_rotation.x, 0, 0)
	
	_input_pitch = 0
	_input_yaw = 0

#endregion

#region Camera

@onready var camera_pivot: Node3D = %CameraPivot
@onready var camera: Camera3D = %Camera3D

@export var allow_turning : bool = true

var _camera_rotation : Vector3

func _process_camera(delta : float) -> void:
	_camera_rotation = Vector3(neck_tilt, 0, 0)
	
	camera_pivot.transform.basis = Basis.from_euler(_camera_rotation)
	camera_pivot.rotation.z = 0
	
	camera.transform.basis = Basis.from_euler(_player_rotation)
	camera.rotation.z = 0
	
	#global_transform.basis = Basis.from_euler(_player_rotation)

	face_renderer.set_head_rotation(_camera_rotation.x, _player_rotation.y)


#endregion

#region Stun

var stunned : bool = false
var stun_recovery : float = 0.0
@export var stun_recovery_ratio : float = 0.7

func stun() -> void:
	if stunned:
		return
	stunned = true
	stun_recovery = 0
	_reset_neck(0.7)
	stun_status_changed.emit(stunned)
	Game.tutorial_manager.request_tutorial(Tutorial.Tag.STUN)

func _reset_neck(duration : float) -> void:
	var tween := get_tree().create_tween()
	tween.tween_property(self, "neck_position", starting_neck_position, duration)
	await tween.finished

func unstun() -> void:
	if not stunned:
		return
	stunned = false
	Game.tutorial_manager.dismiss_tutorial(Tutorial.Tag.STUN)
	stun_status_changed.emit(stunned)
	#var tween := get_tree().create_tween()
	#tween.tween_property(self, "_mouse_rotation", Vector3.ZERO, .6)
	#await tween.finished

var _stamina_recovery_boost_mod : AttributeMod = null
@onready var stamina_regen_timer: Timer = %StaminaRegenTimer

func shake_head() -> void:
	print(_stamina_recovery_boost_mod)
	if not _stamina_recovery_boost_mod:
		var regen_info := AttributeModInfo.new()
		regen_info.mod_type = AttributeModInfo.ModType.ADD_FLAT
		regen_info.mod_value = Game.starting_player_stats.shake_regen_boost
		_stamina_recovery_boost_mod = player_state.stamina_regen_rate.add_modifier(regen_info)
	stamina_regen_timer.start(Game.starting_player_stats.shake_regen_duration)

func _on_stamina_regen_timer_timeout() -> void:
	if _stamina_recovery_boost_mod:
		_stamina_recovery_boost_mod.remove()
		_stamina_recovery_boost_mod = null

func _on_health_value_changed(attribute: Attribute, new_value: float, old_value: float) -> void:
	if new_value <= 0.0 and not stunned:
		stun()
	elif stunned and new_value >= player_state.stamina.max_value * stun_recovery_ratio:
		unstun()

#endregion
#region Kickback

@export var kickback_time: float = .5
@export var kickback_speed: float = 150
var _kickback_acceleration: float = 0

func _add_kickback() -> void:
	var tween: Tween = get_tree().create_tween()
	_kickback_acceleration = kickback_speed
	tween.tween_property(self, "_kickback_acceleration", 0, kickback_time).set_ease(Tween.EASE_OUT)

#endregion
#region pivo anim
var _drinking_pivo: bool = false

@onready var pivo_path: Path3D = %PivoPath3D
@onready var pivo_path_follow: PathFollow3D = %PivoPathFollow3D
@onready var pivo_mug: Node3D = %PivoMug

@export var drinking_time: float = 2

func _start_drinking_pivo() -> void:
	_drinking_pivo = true
	pivo_path_follow.progress_ratio = 0
	_reset_neck(drinking_time / 2 - .2)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(pivo_path_follow, "progress_ratio", 1, drinking_time / 2).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(pivo_path_follow, "progress_ratio", 0, drinking_time / 2).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	_drinking_pivo = false
	player_state.pivo_charges.add_modifier(AttributeModInfo.new(AttributeModInfo.ModType.ADD_FLAT, -1))
	player_state.pivo.activate()

#endregion

var current_hat : Node3D = null
func update_hat() -> void:
	var hp_level : int = player_state.progression_data.get_attribute_level(Attribute.Tag.MAX_STAMINA)
	if hp_level >= 0:
		var hp_progression : AttributeProgressionInfo = Game.progression_config.get_progression_for_attribute(Attribute.Tag.MAX_STAMINA)
		var hat_scene := hp_progression.levels[hp_level].hat_scene
		face_renderer.equip_hat_from_scene(hat_scene)
		if current_hat:
			current_hat.queue_free()
			current_hat = null
		if hat_scene:
			current_hat = hat_scene.instantiate() as Node3D
			Game.player_head.add_child(current_hat)
