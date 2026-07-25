class_name VictoryGameState
extends GameState


func enter(prev_state : State) -> void:
	super.enter(prev_state)

func exit(next_state : State) -> void:
	super.exit(next_state)
	pass

func update(delta: float) -> void:
	super.update(delta)

func physics_update(delta: float) -> void:
	super.physics_update(delta)
