class_name RoundOverGameState
extends GameState


func enter(prev_state : State) -> void:
	super.enter(prev_state)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Game.loose()

func exit(next_state : State) -> void:
	super.exit(next_state)

func update(delta: float) -> void:
	super.update(delta)

func physics_update(delta: float) -> void:
	super.physics_update(delta)
