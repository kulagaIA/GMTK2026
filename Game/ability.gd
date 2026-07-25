class_name Ability
extends Node

enum State {AVAILABLE, ACTIVE, COOLDOWN}

signal state_changed(State)

@export var cooldown: float
@export var duration: float
@export var modifiers: Dictionary[Attribute.Tag, AttributeModInfo]
var _active_mods: Dictionary[Attribute.Tag, AttributeMod]
var _current_state := State.AVAILABLE
@onready var timer: Timer = Timer.new()
var state: Ability.State:
	get:
		return _current_state

func _ready() -> void:
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)

func activate() -> void:
	match _current_state:
		State.AVAILABLE: 
			_current_state = State.ACTIVE
			_add_mods()
			timer.start(duration)
			state_changed.emit(_current_state)

func reset() -> void:
	timer.stop()
	_current_state = State.AVAILABLE
	_remove_mods()

func _add_mods() -> void:
	for tag in modifiers.keys():
		var att_index: int = Game.player_state.get_children().find_custom(func(node: Node) -> bool: return (node is DynamicAttribute) and node.tag == tag)
		if att_index != -1:
			_active_mods[tag] = (Game.player_state.get_child(att_index) as DynamicAttribute).add_modifier(modifiers[tag])

func _remove_mods() -> void:
	for tag in _active_mods.keys():
		var att_index: int = Game.player_state.get_children().find_custom(func(node) -> bool: return node is DynamicAttribute and node.tag == tag)
		if att_index != -1:
			(Game.player_state.get_child(att_index) as DynamicAttribute).remove_modifier(_active_mods[tag])
	_active_mods.clear()

func is_active() -> bool:
	return _current_state == State.ACTIVE

func is_available() -> bool:
	return _current_state == State.AVAILABLE

func is_on_cooldown() -> bool:
	return _current_state == State.COOLDOWN

func _on_timer_timeout() -> void:
	match _current_state:
		State.ACTIVE:
			print("stoped")
			_current_state = State.COOLDOWN
			_remove_mods()
			timer.start(cooldown)
			state_changed.emit(_current_state)
		State.COOLDOWN:
			_current_state = State.AVAILABLE
			state_changed.emit(_current_state)
