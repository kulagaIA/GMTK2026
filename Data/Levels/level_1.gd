class_name Level1Config
extends SmashLevelConfig

@export var level_name: String = "Level 1"
@export var player_stats: BasePlayerStats

func _init() -> void:
	if player_stats == null:
		player_stats = BasePlayerStats.new()
	if smashables.is_empty():
		var melon := MelonSmashableResource.new()
		smashables.append(melon)
