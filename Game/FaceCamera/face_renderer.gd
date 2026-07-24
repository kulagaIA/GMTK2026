class_name FaceRenderer
extends SubViewport

@onready var head: MeshInstance3D = %HeadPlaceholder

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func set_head_color(color: Color) -> void:
	var material := head.get_active_material(0).duplicate()
	material.albedo_color = color
	head.set_surface_override_material(0, material)
