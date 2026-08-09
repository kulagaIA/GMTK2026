class_name SettingsGameState
extends GameState

func enter(prev_state : State) -> void:
	super.enter(prev_state)
	show_screen()

func show_screen() -> void:
	var settings_screen : PackedScene = load("uid://c2jlwfa7qc4xl")
	Game.canvas_manager.push_content_to_layer(JamUtils.layer_ui_menu, settings_screen.instantiate() as Control)

func exit(next_state : State) -> void:
	Game.canvas_manager.clear_layer(JamUtils.layer_ui_menu)
	super.exit(next_state)

func update(delta: float) -> void:
	super.update(delta)

func physics_update(delta: float) -> void:
	super.physics_update(delta)
