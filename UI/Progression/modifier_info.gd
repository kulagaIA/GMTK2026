extends Resource
class_name ModifierInfo

enum TargetType { DAMAGE, MAX_HEALTH, SPEED }

@export var target: TargetType
@export var mod_info: AttributeModInfo
