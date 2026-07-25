class_name Vignette
extends CanvasLayer

@export var inner_radius: float = 0
@export var outer_radius: float = 1

func _process(delta: float) -> void:
	pass

func update(alpha: float, color: Color) -> void:
	(%ColorRect.material as ShaderMaterial).set_shader_parameter("alpha", alpha)
	(%ColorRect.material as ShaderMaterial).set_shader_parameter("color", color)
	(%ColorRect.material as ShaderMaterial).set_shader_parameter("inner_radius", inner_radius)
	(%ColorRect.material as ShaderMaterial).set_shader_parameter("outer_radius", outer_radius)
