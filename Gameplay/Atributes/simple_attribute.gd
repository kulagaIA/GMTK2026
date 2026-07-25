class_name SimpleAttribute
extends Attribute

@export var _starting_value : float = 1.0

@export var has_min_value : bool = true
@export var min_value : float = 0.0
@export var has_max_value : bool = false
@export var max_value : float = 1.0

var _initialized := false
func _init_attribute() -> void:
	if not _initialized:
		_update_cached_value(_starting_value, false)
		_initialized = true

func _enter_tree() -> void:
	_init_attribute()

func set_value(new_value : float) -> void:
	if has_min_value:
		new_value = maxf(min_value, new_value)
	if has_max_value:
		new_value = minf(max_value, new_value)
	_update_cached_value(new_value)

func add(delta : float) -> void:
	set_value(value + delta)
