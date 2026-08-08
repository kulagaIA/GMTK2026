class_name SmashPlayerPreset
extends Resource

@export var display_name: String = "Base Player"
@export var max_stamina: float = 100
@export var stamina_regen: float = 1
@export var stamina_regen_rate: float = 1
@export var stamina_regen_curve: Curve =  preload("res://Data/Player/stamina_regen_curve.tres")
@export var shake_regen_boost: float = 1.0
@export var shake_regen_duration: float = 0.2
@export var damage: float = 20
@export_storage var sensitivity: float = 1
@export var points: int = 0
@export var initial_time: float = 60
@export var crit_chance: float = 10
@export var crit_multiplier: float = 10
@export var pivo_duration: float = 3
@export var pivo_cooldown: float = 5
@export var pivo_damage_resistance: float = 1.0
@export var pivo_crit_chance_multplier: float = 1.0
@export var pivo_charges: int = 1
@export var pivo_charge_per_hit: float = 0.2
