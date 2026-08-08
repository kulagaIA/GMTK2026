extends Control



func _on_timer_timeout() -> void:
	Game.change_game_state(GameState.PROGRESSION)
	queue_free()
