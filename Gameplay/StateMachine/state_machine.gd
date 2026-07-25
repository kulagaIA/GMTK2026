class_name StateMachine
extends Node

signal state_changed(old_state : State, new_state : State)

@export var INITIAL_STATE : State
var states : Dictionary = {}

var state_change_crit_section : bool = false

var _current_state : State
var current_state : State:
	get:
		return _current_state
	set(new_state):
		if new_state == current_state:
			return
		if !new_state:
			# TODO: push_warning?
			return
		assert(not state_change_crit_section)
		state_change_crit_section = true
		var old_state := _current_state
		if old_state:
			old_state.exit(new_state)
		_current_state = new_state
		new_state.enter(old_state)
		state_change_crit_section = false
		state_changed.emit(old_state, new_state)

func _ready() -> void:
	for child in get_children():
		if child is State:
			states[child.name] = child
			child.transition_requested.connect(_on_child_requested_transition)
		else:
			push_warning("State machine %s contains incompatible child node %s" % [get_path(), child.name])

	if not owner.is_node_ready():
		await owner.ready
	if INITIAL_STATE:
		current_state = INITIAL_STATE
	#else:
		#push_warning("Initial state not set for state machine %s" % [get_path()])


func _process(delta: float) -> void:
	if current_state:
		current_state.update(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.physics_update(delta)

func request_transition_external(new_state_name : StringName) -> void:
	_try_switch_to_state(new_state_name)

# TODO: add requesting state ref?
func _on_child_requested_transition(new_state_name : StringName) -> void:
	_try_switch_to_state(new_state_name)

func _try_switch_to_state(new_state_name : StringName) -> bool:
	var new_state : State = states.get(new_state_name)
	if new_state:
		current_state = new_state
		return true
	else:
		push_warning("State machine %s could not transition to state %s (state does not exist)" % [get_path(), str(new_state_name)])
		return false
