class_name Smashable
extends Node3D

@export var data : SmashableResource = null

@onready var max_health: SimpleAttribute = %MaxHealth
@onready var health: SimpleAttribute = %Health
@onready var damage: SimpleAttribute = %Damage
@onready var reward: SimpleAttribute = %Reward

signal destroyed(target: Smashable)
var _destroyed : bool = false
var _view : Node3D = null

@onready var view: SmashableView = %SmashableView
@onready var placeholder_mesh: MeshInstance3D = view.mesh

func _ready() -> void:
	apply_stats(data)
	# TODO: implement SmashableViews
	_view = placeholder_mesh

func _process(delta: float) -> void:
	pass

func apply_stats(stats: SmashableResource) -> void:
	assert(stats)
	max_health.set_value(stats.health)
	health.set_value(stats.health)
	damage.set_value(stats.damage)
	reward.set_value(stats.reward)

func get_base_damage() -> float:
	return damage.value

# HACK: this is hard-coded to be damage to attacker, called before PlayerState
func modify_hit(info: HitInfo) -> void:
	info.damage_to_attacker_modified = info.damage_to_attacker_base

const damage_number_scene: PackedScene = preload("res://Game/damage_number.tscn")

func apply_damage(amount: float) -> void:
	take_damage(amount)

func _on_hit_occurred(info: HitInfo) -> void:
	var damage_number: DamageNumber = damage_number_scene.instantiate()
	damage_number.damage_value = info.damage_to_target_modified
	damage_number.is_crit = info.attacker_crit
	add_child(damage_number)
	damage_number.global_position = global_position

func take_damage(amount: float) -> void:
	health.add(-amount)

func _on_health_value_changed(attribute: Attribute, new_value: float, old_value: float) -> void:
	if not _destroyed:
		#print("Smashable HP left: %f" % [new_value])
		if new_value <= max_health.value / 2:
			pass
		if new_value <= 0.0:
			_destroyed = true
			_view.visible = false
			destroyed.emit(self)
