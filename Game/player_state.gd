class_name SmashPlayerState
extends Node

@onready var max_health: DynamicAttribute = %MaxHealth
@onready var health: SimpleAttribute = %Health
@onready var damage: DynamicAttribute = %Damage
@onready var sensitivity: DynamicAttribute = %Sensitivity
@onready var points: SimpleAttribute = %Points
@onready var initial_time: DynamicAttribute = %InitialTime
@onready var crit_chance: DynamicAttribute = %CritChance
@onready var crit_multiplier: DynamicAttribute = %CritMultiplier
@onready var pivo: Ability = %Pivo
@onready var damage_resistance: DynamicAttribute = %DamageResistance
@onready var pivo_charges: DynamicAttribute = %PivoCharges

const damge_number_scene: PackedScene = preload("res://Game/damage_number.tscn")

var progression_config : SmashProgressionConfig:
	get:
		return Game.progression_config
var progression_data : ProgressionSaveData = ProgressionSaveData.new()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func reset() -> void:
	pivo.reset()
	for mod in pivo_charges.get_children().filter(func(node)->bool: return node is AttributeMod):
		if (mod as AttributeMod).value < 0:
			pivo_charges.remove_modifier(mod)
	health.max_value = max_health.value
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
	damage_resistance.set_value(1)
	pivo_charges.set_value(stats.pivo_charges)
	pivo.duration = stats.pivo_duration
	pivo.cooldown = stats.pivo_cooldown
	pivo.modifiers[Attribute.Tag.CRIT_CHANCE] = AttributeModInfo.new(AttributeModInfo.ModType.ADD_PERCENT, stats.pivo_crit_chance_multplier)
	pivo.modifiers[Attribute.Tag.DAMAGE_RESISTANCE] = AttributeModInfo.new(AttributeModInfo.ModType.ADD_PERCENT, stats.pivo_damage_resistance)

func calculate_damage(info: HitInfo) -> float:
	var multiplier: float = 1.0
	var base_damage: float = info.target.damage.value
	var damage_number: DamageNumber = damge_number_scene.instantiate()
	if randf_range(0, 100) <= crit_chance.value:
		print("crit occured! multiplier: %f" % [crit_multiplier.value])
		multiplier *= crit_multiplier.value
		damage_number.is_crit = true
	var headVelocityAmplitudeMultiplier = remap(info.velocity + info.amplitude, 0.0, 2.0, 0.7, 1.3)
	#print("head velocity+amplitude multiplier=", headVelocityAmplitudeMultiplier)
	damage_number.damage_value = base_damage * multiplier
	add_child(damage_number)
	damage_number.global_position = info.target.global_position
	return base_damage * multiplier

func apply_damage(amount: float) -> void:
	var multiplier: float = damage_resistance.value
	take_damage(amount / multiplier)

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
