extends Control


@onready var countdown_label: Label = $CountdownLabel
@onready var timer: Timer = $Timer

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	countdown_label.text = "%d..." % [int(ceilf(timer.time_left))]


func _on_timer_timeout() -> void:
	queue_free()
