class_name DamageNumber
extends Node3D

@export var duration: float = 2
@export var speed: float = 10
@export var speed_deviation: float = 3
@export var size: float = .5
@export var angle_deviation: float = 1
var damage_value: int
var is_crit: bool
var velocity: Vector3

func _enter_tree() -> void:
	$Label3D.text = str(damage_value)
	if is_crit:
		$Label3D.modulate = Color.DARK_RED
	velocity = Vector3.ZERO
	velocity.y = randfn(speed, speed_deviation)
	velocity.rotated(Vector3.FORWARD, randfn(0, angle_deviation))
	velocity.rotated(Vector3.LEFT, randfn(0, angle_deviation))
	$Label3D.scale = Vector3(size, size, size)

func _process(delta: float) -> void:
	duration -= delta
	if (duration <= 0):
		self.queue_free()
	
	global_position = global_position.move_toward(velocity, delta)
	$Label3D.basis
