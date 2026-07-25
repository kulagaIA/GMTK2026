# Base class for attributes — which are any number-based characteristics a gameplay entity may have
# The concept is mostly copied from Unreal Engine's GAS plugin
@abstract
class_name Attribute
extends Node

enum Tag { NONE, DAMAGE, MAX_HEALTH, HEALTH, SPEED, TIME, REWARD, CRIT_CHANCE, CRIT_MULTIPLIER }
@export var tag : Tag = Tag.NONE

# Emitted whenever attribute value changes
signal value_changed(attribute : Attribute, new_value : float, old_value : float)

var _cached_value : float
var value : float:
	get:
		return _cached_value

func _update_cached_value(new_value : float, emit_signals : bool = true) -> void:
	if new_value == _cached_value:
		return
	if not emit_signals:
		_cached_value = new_value
		return
	var old_value := _cached_value
	_cached_value = new_value
	if emit_signals:
		value_changed.emit(self, new_value, old_value)

# TODO: should modification be in base class?? Basically the only reason it's here is for convenience
@abstract func set_value(new_value : float) -> void
@abstract func add(delta : float) -> void
