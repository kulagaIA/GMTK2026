class_name SmashGameplay
extends Node3D

signal hit_occurred(info: HitInfo)
signal smashable_destroyed(smashables: Array[SmashableResource])

@onready var player: SmashPlayer = %Player
var player_state: SmashPlayerState:
	get:
		return Game.player_state

@export var spawned_queue: SmashQueue
var smashables: Array[SmashableResource] = []

func _ready() -> void:
	Game.gameplay = self
	assert(player_state)
	player_state.reset()
	assert(spawned_queue)
	spawned_queue.smashable_spawned.connect(_on_smashable_queue_smashable_spawned)
	timer.timeout.connect(_on_timer_depleted)


@warning_ignore("unused_parameter")
func _process(delta: float) -> void:
	pass

func restart_gameplay() -> void:
	cleanup_gameplay()
	load_level(Game.level_config)
	player_state.reset()
	var countdown := countdown_scene.instantiate() as Control
	Game.canvas_manager.push_content_to_layer(JamUtils.layer_ui_info, countdown)
	await countdown.tree_exited
	restart_gameplay_timer()
	Game.combo_manager.decay_started = true
	player.handle_gameplay_started()

func cleanup_gameplay() -> void:
	Game.combo_manager.reset_combo()
	smashables.clear()
	spawned_queue.clear_all()

func stop_gameplay() -> void:
	stop_gameplay_timer()
	player.handle_gameplay_ended()

#region Timer

@onready var timer := %GameTimer as GameTimer
@export var countdown_scene : PackedScene

func restart_gameplay_timer() -> void:
	timer.start(player_state.initial_time.value)

func stop_gameplay_timer() -> void:
	timer.stop()

func _on_timer_depleted() -> void:
	Game.change_game_state(GameState.ROUND_OVER)

#endregion

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
