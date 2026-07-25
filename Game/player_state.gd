class_name SmashPlayerState
extends Node

@onready var max_health: DynamicAttribute = %MaxHealth
@onready var health: SimpleAttribute = %Health
@onready var damage: DynamicAttribute = %Damage
@onready var sensitivity: DynamicAttribute = %Sensitivity
@onready var points: SimpleAttribute = %Points
@onready var initial_time: SimpleAttribute = %InitialTime
@onready var crit_chance: DynamicAttribute = %CritChance
@onready var crit_multiplier: DynamicAttribute = %CritMultiplier
@onready var pivo: Pivo = %Pivo

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
	points.set_value(stats.points)
	initial_time.set_value(stats.initial_time)
	crit_chance.set_value(stats.crit_chance)
	crit_multiplier.set_value(stats.crit_multiplier)
	pivo.duration = stats.pivo_duration
	pivo.cooldown = stats.pivo_cooldown
	pivo.damage_resistance = stats.pivo_damage_resistance
	pivo.crit_chance_multiplier = stats.pivo_crit_chance_multplier

func calculate_damage(info: HitInfo) -> float:
	var multiplier: float = 1.0
	var base_damage: float = info.target.damage.value
	if randf_range(0, 100) <= (crit_chance.value * pivo.crit_chance_multiplier if pivo.is_active() else crit_chance.value):
		print("crit occured! multiplier: %f" % [crit_multiplier.value])
		multiplier *= crit_multiplier.value
	print("velocity=", info.velocity)
	print("amplitude=", info.amplitude)
	var headVelocityAmplitudeMultiplier = info.velocity * info.amplitude / 30000
	print("head velocity+amplitude multiplier=", headVelocityAmplitudeMultiplier)
	return base_damage * multiplier

func apply_damage(amount: float) -> void:
	var multiplier: float = 1
	if pivo.is_active():
		multiplier /= pivo.damage_resistance
	take_damage(amount * multiplier)

func _on_hit_occurred(info: HitInfo) -> void:
	if info.attacker == self and info.target is Smashable:
		var self_damage := (info.target as Smashable).calculate_damage(info)
		apply_damage(self_damage)

func take_damage(amount: float) -> void:
	if health != null:
		health.add(-amount)


func _on_health_value_changed(attribute: Attribute, new_value: float, old_value: float) -> void:
	#print("Player HP left: %f" % [new_value])
	if new_value <= 0.0:
		#Game.loose()
		pass

func upgrade_attribute(attribute: Attribute.Tag, new_level: int) -> void:
	var current_level := progression_data.get_attribute_level(attribute)
	assert(current_level < new_level)
	var target_progression := progression_config.get_progression_for_attribute(attribute)
	assert(new_level <= target_progression.max_level)
	var target_attribute := JamUtils.find_tagged_attribute(self, attribute) as DynamicAttribute
	assert(target_attribute)
	while current_level < new_level:
		current_level += 1
		target_attribute.add_modifier(target_progression.levels[current_level].modificator)
	progression_data.attribute_levels.set(attribute, new_level)
