# Register this as a global autoload
extends Node

@export_flags_3d_render var default_camera_layers
@export_flags_3d_render var editor_camera_layers

func _ready() -> void:
	pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_exit"):
		quit_to_desktop()
	elif event.is_action_pressed("debug_mouse"):
		toggle_mouse_cursor()
	elif event.is_action_pressed("debug_dev_view"):
		toggle_dev_view()

func toggle_mouse_cursor() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED else Input.MOUSE_MODE_VISIBLE

#region Jam

@export var default_player_stats : SmashPlayerPreset
var _player_stats_override : SmashPlayerPreset
var starting_player_stats : SmashPlayerPreset:
	get:
		if _player_stats_override:
			return _player_stats_override
		else:
			return default_player_stats

@export var default_level_config : SmashLevelConfig
var _level_config_override : SmashLevelConfig
var level_config : SmashLevelConfig:
	get:
		if _level_config_override:
			return _level_config_override
		else:
			return default_level_config

@export var player_state_scene : PackedScene = null
var player_state : SmashPlayerState = null

func reset_run() -> void:
	_player_stats_override = null
	_level_config_override = null
	if player_state:
		player_state.queue_free()
	player_state = null

func init_run() -> void:
	player_state = player_state_scene.instantiate() as SmashPlayerState
	add_child(player_state)
	player_state.apply_stats(starting_player_stats)

#endregion

#region Pause

var _active_pause_menu : Control

func open_pause_menu() -> void:
	assert(not _active_pause_menu)
	_active_pause_menu = pause_menu_scene.instantiate() as Control
	canvas_manager.push_content_to_layer(JamUtils.layer_ui_menu, _active_pause_menu)

func pause() -> void:
	get_tree().paused = true

func unpause() -> void:
	get_tree().paused = false

#endregion

#region Game

func start_game() -> void:
	load_gameplay_scene()

func restart_level() -> void:
	pre_level_change()
	get_tree().reload_current_scene()
	await get_tree().scene_changed
	post_level_change()

enum StageResult { IN_PROGRESS, LOOSE, WIN }
var stage_result : StageResult = StageResult.IN_PROGRESS

func win() -> void:
	init_game_over(StageResult.WIN)

func loose() -> void:
	init_game_over(StageResult.LOOSE)

func quit_to_title() -> void:
	load_title_scene()

func quit_to_desktop() -> void:
	get_tree().quit()

#endregion

#region Game Over

var _active_game_over_screen : Control

func init_game_over(result : StageResult) -> void:
	assert(not _active_game_over_screen)
	stage_result = result
	_active_game_over_screen = game_over_scene.instantiate() as Control
	canvas_manager.push_content_to_layer(JamUtils.layer_ui_menu, _active_game_over_screen)

#endregion

#region Scenes

@export_category("Scenes")
@export var title_scene : PackedScene
@export var gameplay_scene : PackedScene
@export var pause_menu_scene : PackedScene
@export var game_over_scene : PackedScene
@export var progression_scene : PackedScene

func load_title_scene() -> void:
	load_level(title_scene)

func load_gameplay_scene() -> void:
	load_level(gameplay_scene)

func load_progression_scene() -> void:
	load_level(progression_scene)

func load_level(level_scene : PackedScene) -> void:
	if level_scene:
		pre_level_change()
		get_tree().change_scene_to_packed(level_scene)
		post_level_change()
	else:
		push_error("Trying to load empty level")

func pre_level_change() -> void:
	canvas_manager.clear_layer(JamUtils.layer_ui_menu)
	free_transient_scenes()

func post_level_change() -> void:
	pass

#endregion

#region UI

# TODO: this shall not work in split-scren = cannot make it an autoload
var canvas_manager : CanvasManager = null

#endregion

#region Transients
# TODO: move to separate script
# TODO: support non-Node objects?

# These will be deleted when changing scenes
# TODO: optimize by making it a dictionary?
var transient_scenes : Array[Node]

func register_transient_scene(scene_instance : Node) -> void:
	assert(scene_instance)
	if not transient_scenes.has(scene_instance):
		transient_scenes.append(scene_instance)

func free_transient_scenes() -> void:
	for scene in transient_scenes:
		if is_instance_valid(scene):
			scene.queue_free()

#endregion

#region Dev View
# TODO: move to camera system

func toggle_dev_view() -> void:
	toggle_dev_view_3d()
	toggle_dev_view_2d()

func toggle_dev_view_3d() -> bool:
	var camera_3d := get_viewport().get_camera_3d()
	if camera_3d:
		if camera_3d.cull_mask & editor_camera_layers == 0:
			camera_3d.cull_mask |= editor_camera_layers
		else:
			camera_3d.cull_mask &= ~editor_camera_layers
		return true
	return false

func toggle_dev_view_2d() -> bool:
	if get_viewport().canvas_cull_mask & editor_camera_layers == 0:
		get_viewport().canvas_cull_mask |= editor_camera_layers
	else:
		get_viewport().canvas_cull_mask &= ~editor_camera_layers
	return true

#endregion
