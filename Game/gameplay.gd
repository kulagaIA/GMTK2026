class_name SmashLevel
extends Node3D

signal hit_occurred(attacker: Node, target: Node)

@export var smashable_scene: PackedScene = preload("res://Game/smashable.tscn")

@onready var player: SmashPlayer = %Player
var player_state: SmashPlayerState:
	get:
		return Game.player_state
		
var smashables: Array[Smashable] = []
var _last_mouse_direction: int = 0

func _ready() -> void:
	assert(smashable_scene)
	load_level(Game.level_config)
	self.hit_occurred.connect(player_state._on_hit_occurred)

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

	for child in smashables:
		if child is Node:
			child.queue_free()

	player_state = null
	smashables.clear()

	for smashable_resource in config.smashables:
		spawn_smashable(smashable_resource)

func spawn_smashable(smashable_resource: SmashableResource) -> void:
	if smashable_resource == null:
		return

	var smashable := smashable_scene.instantiate() as Smashable
	add_child(smashable)
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
