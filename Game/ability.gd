class_name Ability
extends Node

enum State {AVAILABLE, ACTIVE, COOLDOWN}

@export var cooldown: float = 5
@export var duration: float = 3
var _current_state := State.AVAILABLE
var state: Ability.State:
	get:
		return _current_state

func activate() -> void:
	match _current_state:
		State.AVAILABLE: 
			_current_state = State.ACTIVE
			print("active")
			await get_tree().create_timer(duration).timeout
			_current_state = State.COOLDOWN
			print("cooldown")
			await get_tree().create_timer(cooldown).timeout
			_current_state = State.AVAILABLE
			print("available")

func is_active() -> bool:
	return _current_state == State.ACTIVE

func is_available() -> bool:
	return _current_state == State.AVAILABLE

func is_on_cooldown() -> bool:
	return _current_state == State.COOLDOWN
