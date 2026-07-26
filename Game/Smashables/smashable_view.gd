class_name SmashableView
extends Node3D

@export_group("Hit Animation")
@export_range(0.5, 1.0, 0.01)
var hit_vertical_scale := 0.75
@export_range(1.0, 1.5, 0.01)
var hit_horizontal_scale := 1.15
@export_range(0.0, 0.5, 0.01)
var hit_bounce_height := 0.08
@export_range(0.01, 1.0, 0.01)
var hit_compress_duration := 0.08
@export_range(0.01, 1.0, 0.01)
var hit_recover_duration := 0.18

@onready var mesh: MeshInstance3D = %Mesh
@onready var visual_root: Node3D = %VisualRoot

var _hit_tween: Tween

func play_hit() -> void:
	if _hit_tween:
		_hit_tween.kill()

	visual_root.position = Vector3.ZERO
	visual_root.scale = Vector3.ONE

	_hit_tween = create_tween()
	_hit_tween.set_parallel()

	# Squash + hop
	_hit_tween.tween_property(
		visual_root,
		"scale",
		Vector3(hit_horizontal_scale, hit_vertical_scale, hit_horizontal_scale),
		hit_compress_duration
	)

	_hit_tween.tween_property(
		visual_root,
		"position:y",
		hit_bounce_height,
		hit_compress_duration
	)

	_hit_tween.chain()

	# Return to normal
	_hit_tween.set_trans(Tween.TRANS_ELASTIC)
	_hit_tween.set_ease(Tween.EASE_OUT)

	_hit_tween.tween_property(
		visual_root,
		"scale",
		Vector3.ONE,
		hit_recover_duration
	)

	_hit_tween.tween_property(
		visual_root,
		"position:y",
		0.0,
		hit_recover_duration
	)
