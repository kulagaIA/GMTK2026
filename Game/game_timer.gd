class_name GameTimer
extends Timer

func add_time(amount: float) -> void:
	start(time_left + amount)
