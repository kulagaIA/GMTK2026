class_name SmashCamera
extends Camera3D


enum Tag { NONE, ACTIVE, MENU, GAMEPLAY, PPROGRESSION, VICTORY}
@export var tag : Tag = Tag.NONE

func _ready() -> void:
	assert(tag != Tag.NONE)
	Game.cameras.set(tag, self)

static func get_active() -> SmashCamera:
	return get_by_tag(Tag.ACTIVE)

static func get_by_tag(target_camera : Tag) -> SmashCamera:
	return Game.cameras[target_camera]

func _process(delta: float) -> void:
	pass

func fly_and_reparent(target : Node3D, duration : float) -> void:
	assert(target)
	if target == get_parent():
		return
	if duration > 0.0:
		var tween := get_tree().create_tween()
		tween.parallel().tween_property(self, "global_position", target.global_position, duration)
		tween.parallel().tween_property(self, "global_rotation", target.global_rotation, duration)
		await tween.finished
	reparent(target, false)
	position = Vector3.ZERO
	rotation = Vector3.ZERO

func reparent_and_fly(target : Node3D, duration : float) -> void:
	assert(target)
	if target == get_parent():
		return
	reparent(target, true)
	if duration > 0.0:
		var tween := get_tree().create_tween()
		tween.parallel().tween_property(self, "position", Vector3.ZERO, duration)
		tween.parallel().tween_property(self, "rotation", Vector3.ZERO, duration)
		await tween.finished
	else:
		position = Vector3.ZERO
		rotation = Vector3.ZERO
