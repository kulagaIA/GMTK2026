extends Label

var gameplay_scene : SmashGameplay:
	get:
		return Game.gameplay

var game_timer : Timer:
	get:
		return gameplay_scene.timer

func _ready() -> void:
	assert(gameplay_scene)

func _process(delta: float) -> void:
	_update_display(game_timer.time_left)

func _update_display(seconds: float) -> void:
	var minutes := int(seconds) / 60 as int
	var secs := int(ceilf(seconds)) % 60 as int
	text = "%02d:%02d" % [minutes, secs]
