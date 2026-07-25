class_name ProgressionGameState
extends GameState

@export var progression_scene : PackedScene

func enter(prev_state : State) -> void:
	super.enter(prev_state)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	var progression_menu := progression_scene.instantiate() as Control
	if progression_menu:
		Game.canvas_manager.set_layer_content(JamUtils.layer_ui_menu, progression_menu)

func exit(next_state : State) -> void:
	Game.canvas_manager.clear_layer(JamUtils.layer_ui_menu)
	super.exit(next_state)

func update(delta: float) -> void:
	super.update(delta)

func physics_update(delta: float) -> void:
	super.physics_update(delta)
