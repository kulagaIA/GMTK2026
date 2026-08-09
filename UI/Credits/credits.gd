extends Control

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	%Text.meta_clicked.connect(_on_link_clicked)

func _on_back_button_pressed() -> void:
	Game.change_game_state(GameState.MENU)
	queue_free()

func _on_link_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
