class_name Smashable
extends Node3D

@onready var max_health: SimpleAttribute = %MaxHealth
@onready var health: SimpleAttribute = %Health
@onready var damage: SimpleAttribute = %Damage

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func apply_stats(stats: Resource) -> void:
	if stats == null:
		return

	if max_health != null:
		max_health.set_value(stats.get("max_health"))
	if health != null:
		health.set_value(stats.get("health"))
	if damage != null:
		damage.set_value(stats.get("damage"))

func calculate_damage(base_amount: float, state: Dictionary = {}) -> float:
	var multiplier: float = 1.0
	if state.has("buff_multiplier"):
		multiplier *= float(state["buff_multiplier"])
	if state.has("debuff_multiplier"):
		multiplier *= float(state["debuff_multiplier"])
	return base_amount * multiplier

func apply_damage(amount: float) -> void:
	take_damage(amount)

func _on_hit_occurred(attacker: Node, target: Node) -> void:
	if target == self and attacker is SmashPlayerState:
		var self_damage := (attacker as SmashPlayerState).calculate_damage((attacker as SmashPlayerState).damage.value, {"debuff_multiplier": 1.0})
		apply_damage(self_damage)

func take_damage(amount: float) -> void:
	if health != null:
		health.add(-amount)
