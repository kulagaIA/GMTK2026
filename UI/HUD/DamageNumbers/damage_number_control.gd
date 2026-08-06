extends Label

@export var duration: float = 2
@export var speed: float = 5
@export var speed_deviation: float = 3
@export var angle_deviation_deg: float = 15.0
var damage_value: float
var is_crit: bool
var velocity: Vector2

func _ready() -> void:
	text = str(int(damage_value))
	if is_crit:
		modulate = Color.ORANGE_RED
	else:
		modulate = Color.YELLOW
	velocity = Vector2.ZERO
	velocity.y = -randfn(speed, speed_deviation)
	velocity = velocity.rotated(deg_to_rad(randfn(0, angle_deviation_deg)))

func _process(delta: float) -> void:
	duration -= delta
	if (duration <= 0):
		self.queue_free()
	
	global_position += velocity * delta
