extends Label

var gameplay_scene : SmashGameplay:
	get:
		return Game.gameplay

func _ready() -> void:
	assert(gameplay_scene)
	if gameplay_scene and gameplay_scene.has_node("GameTimer"):
		var game_timer := gameplay_scene.get_node("GameTimer") as GameTimer
		if game_timer:
			game_timer.time_changed.connect(_on_time_changed)
			_update_display(game_timer.remaining_time)


func _exit_tree() -> void:
	if gameplay_scene and gameplay_scene.has_node("GameTimer"):
		var game_timer := gameplay_scene.get_node("GameTimer") as GameTimer
		if game_timer:
			game_timer.time_changed.disconnect(_on_time_changed)


func _on_time_changed(remaining: float) -> void:
	_update_display(remaining)

func _update_display(seconds: float) -> void:
	var minutes := int(seconds) / 60 as int
	var secs := int(ceilf(seconds)) % 60 as int
	text = "%02d:%02d" % [minutes, secs]
