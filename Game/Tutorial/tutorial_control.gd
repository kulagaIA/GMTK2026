class_name TutorialControl
extends Control


@export var tag : Tutorial.Tag

var manager : Tutorial:
	get:
		return Game.tutorial_manager

func _ready() -> void:
	assert(manager)
	manager.tutorial_requested.connect(_on_tutorial_requested)
	manager.tutorial_dismissed.connect(_on_tutorial_dismissed)

func _exit_tree() -> void:
	if manager:
		manager.tutorial_requested.disconnect(_on_tutorial_requested)
		manager.tutorial_dismissed.disconnect(_on_tutorial_dismissed)


func _on_tutorial_requested(tutorial : Tutorial.Tag) -> void:
	if tag == tutorial:
		visible = true

func _on_tutorial_dismissed(tutorial : Tutorial.Tag) -> void:
	if tag == tutorial:
		visible = false
