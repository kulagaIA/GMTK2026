class_name RoundOverGameState
extends GameState


func enter(prev_state : State) -> void:
	super.enter(prev_state)
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Game.init_game_over(Game.StageResult.LOOSE)

func exit(next_state : State) -> void:
	Game.canvas_manager.clear_layer(JamUtils.layer_ui_menu)
	super.exit(next_state)

func update(delta: float) -> void:
	super.update(delta)

func physics_update(delta: float) -> void:
	super.physics_update(delta)
