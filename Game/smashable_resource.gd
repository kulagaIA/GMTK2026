class_name SmashableResource
extends Resource

@export var display_name: String = "Melon"
@export var health: int = 40
@export var damage: int = 8
@export var reward: int = 10

@export var intact_mesh: Mesh
@export var damaged_mesh: Mesh
@export var broken_mesh: Mesh

@export var debris_meshes: Array[Mesh]
