class_name ComboCounter
extends Control

@onready var combo_label: Label = %ComboLabel
@onready var combo_progress: ProgressBar = %ComboProgress
@onready var rank_label: Label = %RankLabel

var combo_manager : ComboManager:
	get:
		return Game.combo_manager

var config : SmashComboConfig:
	get:
		return combo_manager.config

func _ready() -> void:
	assert(combo_manager)
	combo_manager.combo_level_changed.connect(_on_combo_level_changed)
	_update_combo_level(combo_manager.current_level)

func _process(delta: float) -> void:
	combo_progress.value = combo_manager.combo_progress * combo_progress.max_value

func _exit_tree() -> void:
	if combo_manager:
		combo_manager.combo_level_changed.disconnect(_on_combo_level_changed)

func _on_combo_level_changed(_old_level: int, new_level: int) -> void:
	_update_combo_level(new_level)

func _update_combo_level(value: int) -> void:
	combo_label.text = "COMBO LVL %d" % [value]
	var level_config := config.levels[value]
	rank_label.text = level_config.label
	modulate = level_config.color
