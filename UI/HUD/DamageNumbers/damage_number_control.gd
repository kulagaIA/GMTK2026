extends Label

@export var duration: float = 2
@export var speed: float = 5
@export var speed_deviation: float = 3
@export var angle_deviation_deg: float = 15.0
var damage_value : float = 1.0
var is_crit : bool = false
var amplitude : float = 0.5
var velocity : Vector2
@export var color_from_amplitude : Gradient = null
@export var scale_from_amplitude : Curve = null
@export var crit_color : Color = Color.ORANGE_RED

func _ready() -> void:
	text = str(int(damage_value))
	if is_crit:
		modulate = crit_color
	else:
		modulate = color_from_amplitude.sample(amplitude)
	scale.x = scale_from_amplitude.sample(amplitude)
	scale.y = scale.x
	velocity = Vector2.ZERO
	velocity.y = -randfn(speed, speed_deviation)
	velocity = velocity.rotated(deg_to_rad(randfn(0, angle_deviation_deg)))

func _process(delta: float) -> void:
	duration -= delta
	if (duration <= 0):
		self.queue_free()
	
	global_position += velocity * delta
