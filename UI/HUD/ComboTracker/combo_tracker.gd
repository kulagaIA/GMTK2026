class_name ComboCounter
extends Control

@onready var combo_label: Label = %ComboLabel
@onready var level_visuals: Control = %LevelVisualsRoot
@onready var combo_progress: ProgressBar = %ComboProgress

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
	combo_label.text = "Combo LVL %d" % [value]
	for visual in level_visuals.get_children():
		visual.queue_free()
	var level_config := config.levels[value]
	if level_config.combo_level_visuals:
		var visuals := level_config.combo_level_visuals.instantiate() as Control
		level_visuals.add_child(visuals)
