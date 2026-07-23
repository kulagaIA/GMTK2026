class_name SmashPlayerState
extends Node

@onready var max_health: DynamicAttribute = %MaxHealth
@onready var health: DynamicAttribute = %Health
@onready var damage: DynamicAttribute = %Damage
@onready var sensitivity: DynamicAttribute = %Sensitivity
@onready var points: SimpleAttribute = %Points
@onready var initial_time: SimpleAttribute = %InitialTime

var progression_config : SmashProgressionConfig:
	get:
		return Game.progression_config
var progression_data : ProgressionSaveData = ProgressionSaveData.new()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func reset() -> void:
	health.set_value(max_health.value)

func apply_stats(stats: SmashPlayerPreset) -> void:
	if stats == null:
		return
	
	max_health.set_value(stats.max_health)
	health.set_value(stats.max_health)
	damage.set_value(stats.damage)
	sensitivity.set_value(stats.sensitivity)
	initial_time.set_value(stats.initial_time)

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
	if attacker == self and target is Smashable:
		var self_damage := (target as Smashable).calculate_damage((target as Smashable).damage.value, {"buff_multiplier": 1.0})
		apply_damage(self_damage)

func take_damage(amount: float) -> void:
	if health != null:
		health.add(-amount)


func _on_health_value_changed(attribute: Attribute, new_value: float, old_value: float) -> void:
	print("Player HP left: %f" % [new_value])
	if new_value <= 0.0:
		Game.loose()
