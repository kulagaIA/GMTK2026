class_name SmashPlayerState
extends Node

@onready var max_stamina: DynamicAttribute = %MaxStamina
@onready var stamina: DynamicAttribute = %Stamina
@onready var stamina_regen: DynamicAttribute = %StaminaRegen
@onready var stamina_regen_rate: DynamicAttribute = %StaminaRegenRate
@onready var damage: DynamicAttribute = %Damage
@onready var sensitivity: DynamicAttribute = %Sensitivity
@onready var points: SimpleAttribute = %Points
@onready var initial_time: DynamicAttribute = %InitialTime
@onready var crit_chance: DynamicAttribute = %CritChance
@onready var crit_multiplier: DynamicAttribute = %CritMultiplier
@onready var pivo: Ability = %Pivo
@onready var damage_resistance: DynamicAttribute = %DamageResistance
@onready var pivo_charges: DynamicAttribute = %PivoCharges
@onready var pivo_charge_per_hit: DynamicAttribute = %PivoChargePerHit

@export var stamina_regen_curve: Curve

@export var ampplitude_to_damage: Curve

var progression_config : SmashProgressionConfig:
	get:
		return Game.progression_config
var progression_data : ProgressionSaveData = ProgressionSaveData.new()

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	regenerate_stamina(delta)

func reset() -> void:
	pivo.reset()
	pivo_charges.set_value(0)
	stamina.max_value = max_stamina.value
	stamina.set_value(max_stamina.value)

func apply_stats(stats: SmashPlayerPreset) -> void:
	if stats == null:
		return
	
	max_stamina.set_value(stats.max_stamina)
	stamina.set_value(stats.max_stamina)
	stamina_regen.set_value(stats.stamina_regen)
	stamina_regen_rate.set_value(stats.stamina_regen_rate)
	stamina_regen_curve = stats.stamina_regen_curve
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
	pivo_charge_per_hit.set_value(stats.pivo_charge_per_hit)

func get_base_damage() -> float:
	return damage.value

# HACK: this is hard-coded to be damage to attacker, called after Smashable
func modify_hit(info: HitInfo) -> void:
	var multiplier: float = 1.0
	var base_damage: float = info.damage_to_target_base
	if randf_range(0, 100) <= crit_chance.value:
		#print("crit occured! multiplier: %f" % [crit_multiplier.value])
		multiplier *= crit_multiplier.value
		info.attacker_crit = true
	var headVelocityAmplitudeMultiplier = remap(info.velocity + info.amplitude, 0.0, 2.0, 0.0, 1.0)
	headVelocityAmplitudeMultiplier = ampplitude_to_damage.sample_baked(headVelocityAmplitudeMultiplier)
	#print("head velocity+amplitude multiplier=", headVelocityAmplitudeMultiplier)
	info.damage_to_target_modified = base_damage * multiplier * headVelocityAmplitudeMultiplier
	info.damage_to_attacker_modified /= damage_resistance.value

func _on_hit_occurred(info: HitInfo) -> void:
	if not pivo.is_active():
		pivo_charges.add(pivo_charge_per_hit.value)

func apply_damage(amount: float) -> void:
	consume_stamina(amount)

func consume_stamina(amount: float) -> void:
	if stamina != null:
		stamina.add(-amount)

func _on_health_value_changed(attribute: Attribute, new_value: float, old_value: float) -> void:
	if new_value <= 0.0:
		pass

func regenerate_stamina(delta: float) -> void:
	if stamina.value >= max_stamina.value:
		return
	var stamina_percent := stamina.value / max_stamina.value
	var regen_multiplier := stamina_regen_curve.sample_baked(stamina_percent)
	var regen := stamina_regen.value * stamina_regen_rate.value * regen_multiplier * delta
	stamina.add(regen)
	if stamina.value > max_stamina.value:
		stamina.set_value(max_stamina.value)

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
