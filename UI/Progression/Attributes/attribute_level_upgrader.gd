class_name AttributeLevelUpgrader
extends Control

signal upgraded(attribute : Attribute.Tag)

@export var target_attribute : Attribute.Tag

#region Helpers

var player : SmashPlayerState:
	get:
		return Game.player_state

var points_attribute : Attribute:
	get:
		return player.points

var points_available : int:
	get:
		return int(points_attribute.value)

var save_data : ProgressionSaveData:
	get:
		return player.progression_data

var progression_config : SmashProgressionConfig:
	get:
		return Game.progression_config

#endregion

func _ready() -> void:
	assert(target_attribute != Attribute.Tag.NONE)
	update_info()

## Zero-based!
func get_current_level() -> int:
	return save_data.get_attribute_level(target_attribute)

## Zero-based!
func get_next_level() -> int:
	return get_current_level() + 1

func is_max_level() -> bool:
	var target_progression := progression_config.get_progression_for_attribute(target_attribute)
	return get_current_level() >= target_progression.max_level

func can_upgrade() -> bool:
	var max_level := is_max_level()
	var enough_points := points_available >= get_next_level_cost()
	return not max_level and enough_points

func get_next_level_cost() -> int:
	var target_progression := progression_config.get_progression_for_attribute(target_attribute)
	assert(target_progression)
	var target_level := get_next_level()
	if target_progression.levels.size() > target_level:
		return target_progression.levels[target_level].cost
	return -1

func _on_upgrade_button_pressed() -> void:
	try_upgrade()

func try_upgrade() -> bool:
	var cost := get_next_level_cost()
	if points_available < cost:
		print("Not enough points")
		return false
	Game.tutorial_manager.dismiss_tutorial(Tutorial.Tag.PROGRESSION)
	points_attribute.add(-cost)
	player.upgrade_attribute(target_attribute, get_next_level())
	upgraded.emit(target_attribute)
	update_info()
	Game.player.update_hat()
	return true

@onready var level_label: Label = %LevelLabel
@onready var upgrade_button: Button = %UpgradeButton
@onready var cost_label: Label = %CostLabel

func get_level_text() -> String:
	return str(get_current_level() + 1)

func update_info() -> void:
	level_label.text = get_level_text()
	upgrade_button.disabled = not can_upgrade()
	if is_max_level():
		cost_label.text = "MAX"
	else:
		cost_label.text = str(get_next_level_cost())
