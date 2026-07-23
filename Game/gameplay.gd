class_name SmashLevel
extends Node3D

signal hit_occurred(attacker: Node, target: Node)

@export var level_config: SmashLevelConfig
@export var player_state_scene: PackedScene = preload("res://Game/player_state.tscn")
@export var player_scene: PackedScene = preload("res://Game/player.tscn")
@export var smashable_scene: PackedScene = preload("res://Game/smashable.tscn")

var player_state: SmashPlayerState
var player: SmashPlayer
var smashables: Array[Smashable] = []
var _last_mouse_direction: int = 0

func _ready() -> void:
	if level_config == null:
		level_config = Level1Config.new()
	load_level(level_config)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var direction: int = signi(event.relative.y)
		if direction == 0:
			return
		if direction == 1 and _last_mouse_direction == -1:
			apply_single_hit()
		_last_mouse_direction = direction
	elif event.is_action_pressed("pause"):
		Game.open_pause_menu()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		Game.open_pause_menu()

func load_level(config: SmashLevelConfig) -> void:
	if config == null:
		return

	for child in get_children():
		if child is Node:
			child.queue_free()

	player_state = null
	player = null
	smashables.clear()

	init_player_state(config)
	spawn_player()
	for smashable_resource in config.smashables:
		spawn_smashable(smashable_resource)

func init_player_state(config: SmashLevelConfig) -> void:
	if player_state_scene == null:
		return

	var player_state_instance = player_state_scene.instantiate()
	add_child(player_state_instance)
	player_state = player_state_instance as SmashPlayerState
	if player_state != null:
		var player_stats = config.get("player_stats")
		player_state.apply_stats(player_stats)
		self.hit_occurred.connect(player_state._on_hit_occurred)

func spawn_player() -> void:
	if player_scene == null:
		return
	
	var player_instance = player_scene.instantiate()
	add_child(player_instance)
	player = player_instance as SmashPlayer
	if player != null:
		self.hit_occurred.connect(player._on_hit_occurred)

func spawn_smashable(smashable_resource: SmashableResource) -> void:
	if smashable_scene == null or smashable_resource == null:
		return

	var smashable_instance = smashable_scene.instantiate()
	add_child(smashable_instance)
	var smashable = smashable_instance as Smashable
	if smashable != null:
		smashable.apply_stats(smashable_resource)
		self.hit_occurred.connect(smashable._on_hit_occurred)
		smashables.append(smashable)

func apply_single_hit() -> void:
	if player_state == null or smashables.is_empty():
		return

	var target_smashable: Smashable = smashables[0]
	if target_smashable == null:
		return

	hit_occurred.emit(player_state, target_smashable)
