extends Label

func _ready() -> void:
	if Game.player_state:
		Game.player_state.health.value_changed.connect(_on_player_health_value_changed)
	show_value(Game.player_state.health.value)

func _exit_tree() -> void:
	if Game.player_state:
		Game.player_state.health.value_changed.disconnect(_on_player_health_value_changed)

func _on_player_health_value_changed(attribute: Attribute, new_value: float, old_value: float) -> void:
	show_value(new_value)

func show_value(value : float) -> void:
	text = "HP: %.0f" % [value]
