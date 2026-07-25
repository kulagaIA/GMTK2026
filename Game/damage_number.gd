class_name DamageNumber
extends Node3D

@export var duration: float = 2
@export var speed: float = 10
@export var speed_deviation: float = 3
@export var size: float = .5
@export var angle_deviation: float = .5
var damage_value: int
var is_crit: bool
var velocity: Vector3

func _enter_tree() -> void:
	%Label.text = str(damage_value)
	if is_crit:
		%Label.modulate = Color.DARK_RED
	velocity = Vector3.ZERO
	velocity.y = randfn(speed, speed_deviation)
	velocity = velocity.rotated(Vector3.FORWARD, randfn(0, angle_deviation))
	velocity = velocity.rotated(Vector3.LEFT, randfn(0, angle_deviation))
	print(velocity)
	%Label.scale = Vector3(size, size, size)

func _process(delta: float) -> void:
	duration -= delta
	if (duration <= 0):
		self.queue_free()
	
	global_position = global_position.move_toward(velocity, delta)
	%Label.basis
