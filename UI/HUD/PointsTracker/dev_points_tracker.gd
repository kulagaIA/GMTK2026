class_name DevPointsTracker
extends Label

var gameplay : SmashGameplay:
	get:
		return Game.gameplay

func _ready() -> void:
	assert(gameplay)
	gameplay.smashable_destroyed.connect(_on_smashable_destroyed)
	update_count()

func _exit_tree() -> void:
	if gameplay:
		gameplay.smashable_destroyed.disconnect(_on_smashable_destroyed)

func set_number_to_display(number: int) -> void:
	text = "$: %.0f" % [number]

func _on_smashable_destroyed(smashables: Array[SmashableResource]) -> void:
	update_count()

func update_count() -> void:
	set_number_to_display(int(Game.player_state.points.value))
