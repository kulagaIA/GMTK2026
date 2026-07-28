class_name ComboManager
extends Node

signal combo_level_changed(old_level: int, new_level: int)

var current_combo : float = 0.0
var combo_progress : float:
	get:
		return current_combo / combo_meter_to_next_level
var current_level : int = 0:
	get:
		return current_level
	set(new_level):
		var old_level := current_level
		current_level = new_level
		combo_level_changed.emit(old_level, new_level)

@export var level_drop_cooldown : Timer = null
@export var config : SmashComboConfig
var current_level_config : SmashComboLevelConfig:
	get:
		return config.levels[current_level]

var combo_meter_to_next_level : float:
	get:
		return current_level_config.combo_meter_to_next_level

var next_level_config : SmashComboLevelConfig:
	get:
		if config.levels.size() > current_level + 1:
			return config.levels[current_level + 1]
		else:
			return null

var max_level : int:
	get:
		return config.levels.size() - 1


func _ready() -> void:
	assert(config)

#region Hits

func process_hit(info : HitInfo) -> void:
	var combo_delta := 0.0
	var level_config := current_level_config
	if level_config.combo_points_per_hit > 0.0:
		combo_delta += level_config.combo_points_per_hit
	if level_config.combo_points_per_damage > 0.0:
		combo_delta += info.damage_to_target_modified * level_config.combo_points_per_damage
	if info.target_smashed and level_config.combo_points_per_smash > 0.0:
		combo_delta += level_config.combo_points_per_smash
	add_combo(combo_delta)

func add_combo(amount : float) -> void:
	current_combo += amount
	if current_level < max_level:
		if current_combo > combo_meter_to_next_level:
			increase_level()
	else:
		current_combo = clamp(current_combo, 0.0, combo_meter_to_next_level)

#endregion

func reset_combo() -> void:
	current_combo = 0.0
	current_level = 0

func increase_level() -> void:
	if current_level >= max_level:
		return
	current_combo -= combo_meter_to_next_level
	current_level += 1
	level_drop_cooldown.start()

func try_decrease_level() -> void:
	if not level_drop_cooldown or level_drop_cooldown.is_stopped():
		decrease_level()

func decrease_level() -> void:
	if current_level <= 0:
		return
	current_level -= 1
	current_combo = combo_meter_to_next_level

#region Decay

var active : bool = false

func _process(delta: float) -> void:
	if active:
		_process_decay(delta)

func _process_decay(delta: float):
	if current_combo > 0.0:
		var decay := current_level_config.cooling_rate * delta
		current_combo = max(current_combo - decay, 0)
	if current_combo <= 0.0:
		try_decrease_level()

#endregion
