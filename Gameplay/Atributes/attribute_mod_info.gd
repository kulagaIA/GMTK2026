class_name AttributeModInfo
extends Resource

enum ModType { ADD_FLAT, ADD_PERCENT }

@export var mod_type : ModType
@export var mod_value : float

func _init(type: ModType = ModType.ADD_FLAT, value: float = 0.0) -> void:
	mod_type = type
	mod_value = value
