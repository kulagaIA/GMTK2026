class_name MainMenuGameState
extends GameState

@export var main_menu_scene : PackedScene

func enter(prev_state : State) -> void:
	super.enter(prev_state)
	var main_menu := main_menu_scene.instantiate() as Control
	if main_menu:
		Game.canvas_manager.set_layer_content(JamUtils.layer_ui_menu, main_menu)

func exit(next_state : State) -> void:
	Game.canvas_manager.clear_layer(JamUtils.layer_ui_menu)
	super.exit(next_state)

func update(delta: float) -> void:
	super.update(delta)

func physics_update(delta: float) -> void:
	super.physics_update(delta)
