class_name GameTimer
extends Node

signal time_changed(remaining: float)
signal time_depleted

@export var initial_time := 25.0 as float
@export var min_time := 0.0 as float

var remaining_time: float
var is_running := false as bool

func _ready() -> void:
	remaining_time = initial_time

func _process(delta: float) -> void:
	if not is_running:
		return
	
	remaining_time -= delta
	time_changed.emit(remaining_time)
	
	if remaining_time <= min_time:
		remaining_time = min_time
		is_running = false
		time_depleted.emit()

func start() -> void:
	is_running = true

func pause() -> void:
	is_running = false

func add_time(amount: float) -> void:
	remaining_time += amount
	remaining_time = clamp(remaining_time, min_time, initial_time)
	time_changed.emit(remaining_time)

func reset() -> void:
	remaining_time = initial_time
	is_running = false
