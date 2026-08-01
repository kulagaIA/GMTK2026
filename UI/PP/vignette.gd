@tool
class_name Vignette
extends Control

@export var inner_radius: float = 0.0:
	get:
		return inner_radius
	set(new_radius):
		inner_radius = new_radius
		_material.set_shader_parameter(&"inner_radius", inner_radius)

@export var outer_radius: float = 1.0:
	get:
		return outer_radius
	set(new_radius):
		outer_radius = new_radius
		_material.set_shader_parameter(&"outer_radius", outer_radius)

@export var vignette_color: Color = Color.BLACK:
	get:
		return vignette_color
	set(new_color):
		vignette_color = new_color
		_material.set_shader_parameter(&"color", vignette_color)

@export_range(0.0, 1.0, 0.01) var alpha: float = 1.0:
	get:
		return alpha
	set(new_alpha):
		alpha = new_alpha
		_material.set_shader_parameter(&"alpha", alpha)

var _material : ShaderMaterial:
	get:
		return material as ShaderMaterial

func _ready() -> void:
	_material.set_shader_parameter(&"alpha", alpha)
	_material.set_shader_parameter(&"color", vignette_color)
	_material.set_shader_parameter(&"inner_radius", inner_radius)
	_material.set_shader_parameter(&"outer_radius", outer_radius)
