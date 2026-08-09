extends Control

@onready var dev_progress_bar: ProgressBar = %DevProgressBar
@onready var progress_indicator: TextureRect = %ProgressIndicator

func _ready() -> void:
	if Game.player_state:
		Game.player_state.stamina.value_changed.connect(_on_player_stamina_value_changed)
	show_value(Game.player_state.stamina.value)

func _exit_tree() -> void:
	if Game.player_state:
		Game.player_state.stamina.value_changed.disconnect(_on_player_stamina_value_changed)

func _on_player_stamina_value_changed(attribute: Attribute, new_value: float, old_value: float) -> void:
	show_value(new_value)

func show_value(value : float) -> void:
	var percent : float = Game.player_state.player_stamina_percent
	dev_progress_bar.value = percent * dev_progress_bar.max_value
	progress_indicator.position.y = size.y * percent
