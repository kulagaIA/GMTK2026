class_name SmashableResource
extends Resource

@export var display_name: String = "Melon"
@export var scale: float = 1.0
@export var health: int = 40
@export var damage: int = 8
@export var stamina_decay_flat: float = 0.0
@export var stamina_decay_multiplier: float = 1.0
@export var reward: int = 10

@export var intact_mesh: Mesh
@export var damaged_mesh: Mesh
@export var broken_mesh: Mesh

@export var debris_meshes: Array[Mesh]

@export var normal_hits: Array[AudioStream]
@export var metal_hits: Array[AudioStream]
@export var crit_hits: Array[AudioStream]
@export var destroy: Array[AudioStream]
@export var roll: Array[AudioStream]

func is_a_bomb() -> bool:
	return reward <= 0
