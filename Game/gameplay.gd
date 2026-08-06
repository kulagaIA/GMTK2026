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

var num_smashables_left : int:
	get:
		var result := smashables.filter(
			func(smashable : SmashableResource): return smashable.display_name != "Bomb").size() + spawned_queue.active_smashables.filter(
			func(smashable : Smashable): return smashable.data.display_name != "Bomb").size()
		if spawned_queue.current_smashable.health.value <= 0.0:
			result -= 1
		return result

const BOMB_RESOURCE = preload("res://Data/Smashables/bomb.tres")
@export var seconds_before_bomb_skip: float = 1.5

func _ready() -> void:
	Game.gameplay = self
	assert(player_state)
	player_state.reset()
	assert(spawned_queue)
	spawned_queue.smashable_spawned.connect(_on_smashable_queue_smashable_spawned)
	#hit_occurred.connect(Game.combo_manager.process_hit)
	timer.timeout.connect(_on_timer_depleted)


var seconds_since_bomb : float = 0
func _process(delta: float) -> void:
	if((spawned_queue.current_smashable)
		&& (spawned_queue.current_smashable.data.display_name == 'Bomb')
		&& (Game.game_state_machine.current_state.name == "Gameplay")):
		seconds_since_bomb += delta
	if (seconds_since_bomb >= seconds_before_bomb_skip):
		print("bomb skipped")
		seconds_since_bomb = 0
		queue_smashables(1)
		spawned_queue.advance_queue()
		print("Smashables left: %d spawned, %d queued" % [spawned_queue.active_smashables.size(), smashables.size()])
		smashable_destroyed.emit(smashables)


func restart_gameplay() -> void:
	cleanup_gameplay()
	load_level(Game.level_config)
	player_state.reset()
	var countdown := countdown_scene.instantiate() as Control
	Game.canvas_manager.push_content_to_layer(JamUtils.layer_ui_info, countdown)
	await countdown.tree_exited
	Game.tutorial_manager.request_tutorial(Tutorial.Tag.SWING)
	if player_state.pivo_charges.value >= 1.0:
		Game.tutorial_manager.request_tutorial(Tutorial.Tag.BEER)
	restart_gameplay_timer()
	Game.combo_manager.active = true
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
	#if player_state == null or num_smashables_left < 1:
	if player_state == null:
		return

	var target_smashable: Smashable = spawned_queue.current_smashable
	if target_smashable == null:
		return
	#if target_smashable.health.value <= 0.0:
		#return
	
	var info := HitInfo.new()
	info.attacker = player_state
	info.target = target_smashable
	info.velocity = velocity
	info.amplitude = amplitude
	
	info.damage_to_target_base = player_state.damage.value
	info.damage_to_attacker_base = target_smashable.damage.value

	# HACK: this is just sad
	target_smashable.modify_hit(info)
	player_state.modify_hit(info)
	
	info.target_smashed = target_smashable.health.value <= info.damage_to_target_modified
	info.attacker_stunned = player_state.stamina.value <= info.damage_to_attacker_modified
	
	target_smashable.apply_damage(info.damage_to_target_modified)
	player_state.apply_damage(info.damage_to_attacker_modified)
	
	hit_occurred.emit(info)

func get_combo_points_nultiplier() -> float:
	return Game.combo_manager.current_level_config.points_multiplier

@export var boss_type : SmashableResource

func _on_smashable_destroyed(target: Smashable) -> void:
	var base_reward := target.reward.value
	Game.player_state.points.add(base_reward * get_combo_points_nultiplier())
	if target.data == boss_type:
		Game.win()
		smashable_destroyed.emit(smashables)
	else:
		queue_smashables(1)
		spawned_queue.advance_queue()
		print("Smashables left: %d spawned, %d queued" % [spawned_queue.active_smashables.size(), smashables.size()])
		smashable_destroyed.emit(smashables)
		Game.tutorial_manager.dismiss_tutorial(Tutorial.Tag.SWING)

#endregion

#region Initialization

func load_level(config: SmashLevelConfig) -> void:
	if config == null:
		return
		
	var pools : Array[SmashablesPool] = Game.level_config.pools
	var bomb_count : int = randi_range(Game.level_config.bomb_min_amount, Game.level_config.bomb_max_amount)
	var available_positions: Array[int] = []
	var pools_sum_size : int = 0
	for pool : SmashablesPool in pools:
		pools_sum_size += pool.count
	for i in range(Game.level_config.bomb_min_space_between, pools_sum_size - Game.level_config.bomb_min_space_between):
		available_positions.append(i)
	available_positions.shuffle()
	var selected_positions: Array[int] = []
	
	for position in available_positions:
		var valid := true
		for selected in selected_positions:
			if abs(position - selected) <= Game.level_config.bomb_min_space_between:
				valid = false
				break
		if valid:
			selected_positions.append(position)
			if selected_positions.size() >= bomb_count:
				break
	selected_positions.sort()

	print("inserted bombs on positions ", selected_positions)
	var current_insert_pos = 0
	for pool in config.pools:
		for idx in range(pool.count):
			if selected_positions.find(current_insert_pos) != -1 :
				smashables.append(BOMB_RESOURCE.duplicate(true))
			smashables.append(pool.smashable)
			current_insert_pos += 1
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
