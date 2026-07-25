class_name DevPointsTracker
extends Label

func _ready() -> void:
	if Game.gameplay:
		Game.gameplay.smashable_destroyed.connect(_on_smashable_destroyed)

func _exit_tree() -> void:
	if Game.gameplay:
		Game.gameplay.smashable_destroyed.disconnect(_on_smashable_destroyed)

func set_number_to_display(number: int) -> void:
	text = "Points: %.0f" % [number]

func _on_smashable_destroyed(smashables: Array[SmashableResource]) -> void:
	text = "Points: %.0f" % [Game.player_state.points.value]
