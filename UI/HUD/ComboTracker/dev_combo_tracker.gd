extends Label

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

func _exit_tree() -> void:
	if combo_manager:
		combo_manager.combo_level_changed.disconnect(_on_combo_level_changed)

func _on_combo_level_changed(_old_level: int, new_level: int) -> void:
	_update_combo_level(new_level)

func _update_combo_level(value: int) -> void:
	text = "Combo LVL %d" % [value]
