extends Node3D


func _ready() -> void:
	Game.change_game_state(GameState.MENU)


func _process(delta: float) -> void:
	pass
