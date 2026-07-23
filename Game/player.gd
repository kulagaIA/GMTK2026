class_name SmashPlayer
extends Node3D

@onready var camera_pivot: Node3D = %CameraPivot
@onready var camera: Camera3D = %Camera3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_hit_occurred(attacker: Node, target: Node) -> void:
	pass
