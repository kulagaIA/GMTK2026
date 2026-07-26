class_name Smashable
extends Node3D

@export var data : SmashableResource = null

@onready var max_health: SimpleAttribute = %MaxHealth
@onready var health: SimpleAttribute = %Health
@onready var damage: SimpleAttribute = %Damage
@onready var reward: SimpleAttribute = %Reward

signal destroyed(target: Smashable)
var _destroyed : bool = false

@onready var _view: SmashableView = %SmashableView
@onready var _mesh: MeshInstance3D = _view.mesh

enum DamageStage {
	INTACT,
	DAMAGED,
	BROKEN
}

var _stage := DamageStage.INTACT

func _ready() -> void:
	apply_stats(data)

func _process(delta: float) -> void:
	pass

func apply_stats(stats: SmashableResource) -> void:
	assert(stats)
	max_health.set_value(stats.health)
	health.set_value(stats.health)
	damage.set_value(stats.damage)
	reward.set_value(stats.reward)
	_mesh.mesh = data.intact_mesh

func get_base_damage() -> float:
	return damage.value

# HACK: this is hard-coded to be damage to attacker, called before PlayerState
func modify_hit(info: HitInfo) -> void:
	info.damage_to_attacker_modified = info.damage_to_attacker_base

const damage_number_scene: PackedScene = preload("res://Game/damage_number.tscn")

func apply_damage(amount: float) -> void:
	take_damage(amount)

func _on_hit_occurred(info: HitInfo) -> void:
	if info.target == self:
		var damage_number: DamageNumber = damage_number_scene.instantiate()
		damage_number.damage_value = info.damage_to_target_modified
		damage_number.is_crit = info.attacker_crit
		add_child(damage_number)
		damage_number.global_position = global_position
		_view.play_hit()
		_update_damage_stage()

func take_damage(amount: float) -> void:
	health.add(-amount)

func _on_health_value_changed(attribute: Attribute, new_value: float, old_value: float) -> void:
	if not _destroyed:
		#print("Smashable HP left: %f" % [new_value])
		if new_value <= 0.0:
			_destroyed = true
			_view.visible = false
			destroyed.emit(self)

func _update_damage_stage() -> void:
	var ratio := health.value / max_health.value

	if ratio <= 0.0:
		if _stage != DamageStage.BROKEN:
			_stage = DamageStage.BROKEN
			_mesh.mesh = data.broken_mesh
	elif ratio <= 0.5:
		if _stage != DamageStage.DAMAGED:
			_stage = DamageStage.DAMAGED
			_mesh.mesh = data.damaged_mesh
	else:
		if _stage != DamageStage.INTACT:
			_stage = DamageStage.INTACT
			_mesh.mesh = data.intact_mesh
