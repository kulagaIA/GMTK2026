class_name SmashLevel
extends Node3D

signal hit_occurred(attacker: Node, target: Node)

@export var smashable_scene: PackedScene = preload("res://Game/smashable.tscn")

@onready var player: SmashPlayer = %Player
var player_state: SmashPlayerState:
	get:
		return Game.player_state

var smashables: Array[Smashable] = []

func _ready() -> void:
	assert(smashable_scene)
	assert(player_state)
	player_state.reset()
	load_level(Game.level_config)
	self.hit_occurred.connect(player_state._on_hit_occurred)

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

#region Smashing

func _on_player_hit(magnitude: float) -> void:
	apply_single_hit(magnitude)

func apply_single_hit(magnitude: float) -> void:
	if player_state == null or smashables.is_empty():
		return

	var target_smashable: Smashable = smashables[0]
	if target_smashable == null:
		return

	hit_occurred.emit(player_state, target_smashable)

func _on_smashable_destroyed(target: Smashable) -> void:
	smashables.erase(target)
	if target:
		target.queue_free()
		print("Smashables left: %d" % [smashables.size()])

#endregion

#region Initialization

func load_level(config: SmashLevelConfig) -> void:
	if config == null:
		return

	for child in smashables:
		if child is Node:
			child.queue_free()

	player_state = null
	smashables.clear()

	for pool in config.pools:
		for idx in range(pool.count):
			spawn_smashable(pool.smashable)

func spawn_smashable(smashable_resource: SmashableResource) -> void:
	if smashable_resource == null:
		return

	var smashable := smashable_scene.instantiate() as Smashable
	add_child(smashable)
	if smashable != null:
		smashable.apply_stats(smashable_resource)
		self.hit_occurred.connect(smashable._on_hit_occurred)
		smashable.destroyed.connect(self._on_smashable_destroyed)
		smashables.append(smashable)

#endregion
