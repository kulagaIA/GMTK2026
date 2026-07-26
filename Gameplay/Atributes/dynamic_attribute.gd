class_name DynamicAttribute
extends SimpleAttribute

var _base_value : float = 1.0
var base_value : float:
	get:
		return _base_value
	set(value):
		_base_value = value
		_request_value_update()

var percent : float:
	get:
		if has_max_value:
			# TODO: subtract min value
			return value / max_value
		else:
			# FIXME: undefined
			return 1.0

func _init_attribute() -> void:
	if not _initialized:
		_base_value = _starting_value
		_initialized = true

func set_value(new_value : float) -> void:
	base_value = new_value

func add(delta : float) -> void:
	base_value += delta

func _request_value_update() -> void:
	_update_cached_value(recalculate_value())

func recalculate_value() -> float:
	var total_flat_bonus : float = 0
	var total_percent_bonus : float = 0
	for mod in get_active_modifiers():
		match mod.type:
			AttributeModInfo.ModType.ADD_FLAT:
				total_flat_bonus += mod.value
			AttributeModInfo.ModType.ADD_PERCENT:
				total_percent_bonus += mod.value
	var new_value = (base_value + total_flat_bonus) * max(0.0, 1.0 + total_percent_bonus)
	if has_min_value:
		new_value = max(min_value, new_value)
	if has_max_value:
		new_value = min(max_value, new_value)
	return new_value

#region Modifiers

func add_modifier(mod_info : AttributeModInfo) -> AttributeMod:
	var new_mod = AttributeMod.new()
	new_mod.info = mod_info
	add_child(new_mod)
	_request_value_update()
	return new_mod

func remove_modifier(mod : AttributeMod):
	if is_ancestor_of(mod):
		remove_child(mod)
		mod.queue_free()
		_request_value_update()

func get_active_modifiers() -> Array[AttributeMod]:
	var result : Array[AttributeMod]
	result.assign(get_children())
	return result

#endregion
