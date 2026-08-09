extends Control


@onready var countdown_label: Label = $CountdownLabel
@onready var timer: Timer = $Timer

func _ready() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#Game.pause()
	pass


func _process(delta: float) -> void:
	#countdown_label.text = "%d..." % [int(ceilf(timer.time_left))]
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed():
		queue_free()
	if event is InputEventMouseButton and event.is_pressed():
		queue_free()

func _on_timer_timeout() -> void:
	queue_free()


func _on_start_button_pressed() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	queue_free()
	#Game.unpause()
