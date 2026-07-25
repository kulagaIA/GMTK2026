class_name SmashGameplay
extends Node3D

signal hit_occurred(info: HitInfo)
signal smashable_destroyed(smashables: Array[SmashableResource])

@export var smashable_scene: PackedScene = preload("res://Game/smashable.tscn")

@onready var player: SmashPlayer = %Player
var player_state: SmashPlayerState:
	get:
		return Game.player_state

@onready var timer := %GameTimer as GameTimer
@onready var spawned_queue: SmashQueue = %SmashableQueue
var smashables: Array[SmashableResource] = []

func _ready() -> void:
	assert(smashable_scene)
	assert(player_state)
	player_state.reset()
	load_level(Game.level_config)
	self.hit_occurred.connect(player_state._on_hit_occurred)
	
	timer.time_depleted.connect(_on_timer_depleted)
	timer.initial_time = player_state.initial_time.value
	timer.reset()
	timer.start()
	
	Game.combo_manager.decay_started = true
	
	Game.gameplay = self
	
	player_state.health.value_changed.connect(_on_health_value_changed)

func _on_timer_depleted() -> void:
	Game.loose()

@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

#region Smashing

func _on_player_hit(velocity: float, amplitude: float) -> void:
	apply_single_hit(velocity, amplitude)

func apply_single_hit(velocity: float, amplitude: float) -> void:
	player.face_renderer.set_head_color(Color.YELLOW)
	Game.combo_manager.add_combo()
	if player_state == null or smashables.is_empty():
		return

	var target_smashable: Smashable = spawned_queue.current_smashable
	if target_smashable == null:
		return
	
	var info:= HitInfo.new()
	info.attacker = player_state
	info.target = target_smashable
	info.velocity = velocity
	info.amplitude = amplitude
	hit_occurred.emit(info)

func _on_smashable_destroyed(target: Smashable) -> void:
	Game.player_state.points.add(target.reward.value)
	queue_smashables(1)
	spawned_queue.advance_queue()
	print("Smashables left: %d spawned, %d queued" % [spawned_queue.active_smashables.size(), smashables.size()])
	smashable_destroyed.emit(smashables)

#endregion

#region Initialization

func load_level(config: SmashLevelConfig) -> void:
	if config == null:
		return

	smashables.clear()

	for pool in config.pools:
		for idx in range(pool.count):
			smashables.append(pool.smashable)
	queue_smashables(spawned_queue.queue_size)

func _on_smashable_queue_smashable_spawned(smashable: Smashable) -> void:
	self.hit_occurred.connect(smashable._on_hit_occurred)
	smashable.destroyed.connect(self._on_smashable_destroyed)

func queue_smashables(count : int = 1) -> void:
	for idx in range(count):
		if smashables.is_empty():
			return
		spawned_queue.spawn_to_queue(smashables.pop_front())

#endregion

#region PP

@export var vignette_threshold: float = 60
@export var vignette_color: Color = Color.DARK_RED
const vignette_scene: PackedScene = preload("res://PP/vignette.tscn")
var vignette: Vignette = null

func _update_vignette() -> void:
	print("jere ")
	if vignette == null:
		vignette = vignette_scene.instantiate() as Vignette
		get_tree().root.add_child(vignette)
	vignette.update(clampf(1 - Game.player_state.health.value / vignette_threshold, 0, 1), vignette_color)

func _on_health_value_changed(attribute : Attribute, new_value : float, old_value : float) -> void:
	if new_value <= vignette_threshold:
		_update_vignette()
#endregion
