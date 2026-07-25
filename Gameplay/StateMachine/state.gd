class_name State
extends Node

signal transition_requested(new_state_name : StringName)

func enter(prev_state : State) -> void:
	pass

func exit(next_state : State) -> void:
	pass

# TODO: use _process/_physics_process + process mode?
func update(delta: float) -> void:
	pass

func physics_update(delta: float) -> void:
	pass

func request_transition(new_state_name : StringName) -> void:
	transition_requested.emit(new_state_name)
