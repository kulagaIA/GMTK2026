class_name DamageNumber
extends Node3D

@export var duration: float = 2
@export var speed: float = 5
@export var speed_deviation: float = 3
@export var size: float = .5
@export var angle_deviation_deg: float = 15.0
var damage_value: float
var is_crit: bool
var velocity: Vector3

@onready var label: Label3D = %Label

func _ready() -> void:
	label.text = str(int(damage_value))
	if is_crit:
		label.modulate = Color.DARK_RED
	velocity = Vector3.ZERO
	velocity.y = randfn(speed, speed_deviation)
	velocity = velocity.rotated(Vector3.FORWARD, deg_to_rad(randfn(0, 15.0)))
	velocity = velocity.rotated(Vector3.RIGHT, deg_to_rad(randfn(-5.0, 15.0)))
	label.scale = Vector3(size, size, size)

func _process(delta: float) -> void:
	duration -= delta
	if (duration <= 0):
		self.queue_free()
	
	global_position += velocity * delta
