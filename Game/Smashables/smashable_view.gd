class_name SmashableView
extends Node3D

@onready var mesh: MeshInstance3D = %Mesh
@onready var visual_root: Node3D = %VisualRoot

func configure(data: SmashableResource) -> void:
	mesh.mesh = data.intact_mesh
	_debris_meshes = data.debris_meshes
	scale = Vector3.ONE * data.scale

#region Play Hit

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
#endregion

#region Play Destroy
@export_group("Debris")
@export_range(1, 100, 1)
var debris_particle_count := 4
@export_range(0.0, 360.0, 1.0)
var debris_spread_degrees := 180.0
@export_range(0.0, 100.0, 0.1)
var debris_initial_velocity_min := 2.0
@export_range(0.0, 100.0, 0.1)
var debris_initial_velocity_max := 4.0
@export
var debris_direction := Vector3.UP
@export
var debris_gravity := Vector3(0.0, -9.8, 0.0)
@export_range(0.05, 10.0, 0.05)
var debris_lifetime := 0.6
@export_range(0.0, 2.0, 0.01)
var debris_explosiveness := 1.0
@export_range(0.0, 5.0, 0.01)
var debris_preprocess := 0.0

var _debris_meshes: Array[Mesh]

func play_destroy() -> void:
	_spawn_debris()
	#_play_break_sound()

func _spawn_debris() -> void:
	for debris_mesh in _debris_meshes:
		var particles := GPUParticles3D.new()

		particles.one_shot = true
		particles.amount = debris_particle_count
		particles.lifetime = debris_lifetime
		particles.explosiveness = debris_explosiveness
		particles.preprocess = debris_preprocess
		particles.emitting = false

		particles.draw_pass_1 = debris_mesh

		var material := ParticleProcessMaterial.new()
		material.direction = debris_direction
		material.spread = debris_spread_degrees
		material.initial_velocity_min = debris_initial_velocity_min
		material.initial_velocity_max = debris_initial_velocity_max
		material.gravity = debris_gravity

		particles.process_material = material

		add_child(particles)
		particles.global_position = mesh.global_position

		particles.restart()
		particles.emitting = true
#endregion
