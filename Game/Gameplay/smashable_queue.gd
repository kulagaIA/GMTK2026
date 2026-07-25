class_name SmashQueue
extends Node3D

signal smashable_spawned(smashable: Smashable)

@export var smashable_scene: PackedScene = preload("res://Game/Smashables/smashable.tscn")

func _ready() -> void:
	pass

var current_smashable : Smashable:
	get:
		if not active_smashables.is_empty():
			return active_smashables[0]
		else:
			return null
var active_smashables : Array[Smashable]
var _trash_smashables : Array[Smashable]


@onready var queue_root: Node3D = %QueueRoot
@export var queue_size : int = 3
@export var trash_size : int = 3
@export var queue_spacing : float = 1.0
@export var queue_advance_delay : float = 0.1
@export var queue_advance_time : float = 1.0
@export var queue_tween_transition : Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
@export var queue_tween_easing : Tween.EaseType = Tween.EaseType.EASE_OUT
var _total_objects_added : int = 0

var _active_tweener : Tween = null

func advance_queue() -> void:
	if _active_tweener:
		return
	_active_tweener = get_tree().create_tween()
	_active_tweener.tween_interval(queue_advance_delay)
	_active_tweener.tween_property(queue_root, "position", queue_root.position + Vector3.RIGHT * queue_spacing, queue_advance_time).set_trans(queue_tween_transition).set_ease(queue_tween_easing)
	await _active_tweener.finished
	_trash_smashables.push_back(active_smashables.pop_front())
	_active_tweener = null
	_cleanup_trash()

func spawn_smashable(resource: SmashableResource) -> Smashable:
	var smashable := smashable_scene.instantiate() as Smashable
	smashable.data = resource
	smashable_spawned.emit(smashable)
	return smashable

func add_to_queue(item: Smashable) -> Smashable:
	item.position = Vector3.LEFT * _total_objects_added * queue_spacing
	assert(not item.is_inside_tree())
	queue_root.add_child(item)
	_total_objects_added += 1
	active_smashables.push_back(item)
	return item

func spawn_to_queue(resource: SmashableResource) -> Smashable:
	var smashable := spawn_smashable(resource)
	return add_to_queue(smashable)

func _cleanup_trash() -> void:
	while _trash_smashables.size() > trash_size:
		_trash_smashables.pop_front().queue_free()

func clear_all() -> void:
	for smashable in _trash_smashables:
		smashable.queue_free()
	_trash_smashables.clear()
	for smashable in active_smashables:
		smashable.queue_free()
	active_smashables.clear()
	_total_objects_added = 0
	queue_root.position = Vector3.ZERO
