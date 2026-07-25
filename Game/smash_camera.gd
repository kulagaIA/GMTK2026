class_name SmashCamera
extends Camera3D


func _ready() -> void:
	Game.camera = self


func _process(delta: float) -> void:
	pass

func fly_and_reparent(target : Node3D, duration : float) -> void:
	assert(target)
	var tween := get_tree().create_tween()
	tween.parallel().tween_property(self, "global_position", target.global_position, duration)
	tween.parallel().tween_property(self, "global_rotation", target.global_rotation, duration)
	await tween.finished
	reparent(target, false)
	position = Vector3.ZERO
	rotation = Vector3.ZERO

func reparent_and_fly(target : Node3D, duration : float) -> void:
	assert(target)
	reparent(target, true)
	var tween := get_tree().create_tween()
	tween.parallel().tween_property(self, "position", Vector3.ZERO, duration)
	tween.parallel().tween_property(self, "rotation", Vector3.ZERO, duration)
	await tween.finished
