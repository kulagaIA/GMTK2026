extends Control


@onready var countdown_label: Label = $CountdownLabel
@onready var timer: Timer = $Timer

func _ready() -> void:
	Game.gameplay.player.face_renderer.init_hat()


func _process(delta: float) -> void:
	countdown_label.text = "%d..." % [int(ceilf(timer.time_left))]


func _on_timer_timeout() -> void:
	queue_free()
