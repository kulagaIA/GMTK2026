extends Control

@onready var vignette: Vignette = %Vignette
@onready var bubbles: CPUParticles2D = %Bubbles

func _ready() -> void:
	bubbles.emission_rect_extents = Vector2(size.x / 2.0, 1.0)
	bubbles.position = Vector2(size.x / 2.0, size.y + 20.0)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
