extends Label

@export_group("Regular Numbers")
@export var size_px: int = 32
@export var duration: float = 2
@export var speed: float = 5
@export var speed_deviation: float = 3
@export var angle_deviation_deg: float = 15.0
@export var color_from_amplitude : Gradient = null
@export var scale_from_amplitude : Curve = null
@export var shadow_color = Color(0, 0, 0, 0.5)
@export var shadow_offset = Vector2(2, 2)
@export var shadow_size = 3
@export var outline_size = 6
@export var outline_color = Color.BLACK

@export_group("Crit Numbers")
@export var crit_size_px: int = 32
@export var crit_duration: float = 2
@export var crit_speed: float = 5
@export var crit_speed_deviation: float = 3
@export var crit_angle_deviation_deg: float = 15.0
@export var crit_color_from_amplitude : Gradient = null
@export var crit_scale_from_amplitude : Curve = null
@export var crit_shadow_color = Color(0, 0, 0, 0.5)
@export var crit_shadow_offset = Vector2(2, 2)
@export var crit_shadow_size = 3
@export var crit_outline_size = 6
@export var crit_outline_color = Color.BLACK

var damage_value : float = 1.0
var is_crit : bool = false
var amplitude : float = 0.5
var velocity : Vector2
var display_duration : float = 2

func _ready() -> void:
	text = str(int(damage_value))
	if label_settings:
		self.label_settings = label_settings.duplicate()
	else:
		self.label_settings = LabelSettings.new()
	if is_crit:
		modulate = crit_color_from_amplitude.sample(amplitude)
		scale.x = crit_scale_from_amplitude.sample(amplitude)
		velocity.y = -randfn(crit_speed, crit_speed_deviation)
		velocity = velocity.rotated(deg_to_rad(randfn(0, crit_angle_deviation_deg)))
		display_duration = crit_duration
		self.label_settings.shadow_color = crit_shadow_color
		self.label_settings.shadow_offset = crit_shadow_offset
		self.label_settings.shadow_size = crit_shadow_size
		self.label_settings.outline_size = crit_outline_size
		self.label_settings.outline_color = crit_outline_color
		self.label_settings.font_size = crit_size_px
	else:
		modulate = color_from_amplitude.sample(amplitude)
		scale.x = scale_from_amplitude.sample(amplitude)
		velocity.y = -randfn(speed, speed_deviation)
		velocity = velocity.rotated(deg_to_rad(randfn(0, angle_deviation_deg)))
		display_duration = duration
		self.label_settings.shadow_color = shadow_color
		self.label_settings.shadow_offset = shadow_offset
		self.label_settings.shadow_size = shadow_size
		self.label_settings.outline_size = outline_size
		self.label_settings.outline_color = outline_color
		self.label_settings.font_size = size_px
	scale.y = scale.x
	velocity = Vector2.ZERO

func _process(delta: float) -> void:
	display_duration -= delta
	if (display_duration <= 0):
		self.queue_free()
	
	global_position += velocity * delta
