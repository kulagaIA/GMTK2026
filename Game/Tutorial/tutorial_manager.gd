class_name Tutorial
extends Node

enum Tag { NONE, SWING, STUN, PROGRESSION, BEER }

signal tutorial_requested(tag : Tag)
signal tutorial_dismissed(tag : Tag)

var _tutorials_completed : Array

func reset_all_tutorials() -> void:
	_tutorials_completed.clear()

func request_tutorial(tag : Tag) -> bool:
	if _tutorials_completed.has(tag):
		return false
	else:
		tutorial_requested.emit(tag)
		return true

func dismiss_tutorial(tag : Tag) -> void:
	if not _tutorials_completed.has(tag):
		_tutorials_completed.append(tag)
	tutorial_dismissed.emit(tag)
