extends Control

@onready var spawn_area: Control = %SpawnArea

const damage_number_scene = preload("uid://curu41idkrxcx")

func _ready() -> void:
	Game.gameplay.hit_occurred.connect(_on_hit_occurred)


func _on_hit_occurred(info: HitInfo) -> void:
	var damage_number := damage_number_scene.instantiate() as Control
	damage_number.damage_value = info.damage_to_target_modified
	damage_number.amplitude = info.amplitude
	damage_number.is_crit = info.attacker_crit
	spawn_area.add_child(damage_number)
	damage_number.position.x = randf_range(0.0, spawn_area.size.x)
	damage_number.position.y = randf_range(0.0, spawn_area.size.y)
