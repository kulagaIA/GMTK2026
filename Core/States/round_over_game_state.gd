class_name RoundOverGameState
extends GameState


func enter(prev_state : State) -> void:
	super.enter(prev_state)
	show_screen()

func show_screen() -> void:
	#Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	#Game.init_game_over(Game.StageResult.LOOSE)
	var round_over_screen : PackedScene = load("uid://djrvg3jh7j6nq")
	Game.canvas_manager.push_content_to_layer(JamUtils.layer_ui_info, round_over_screen.instantiate() as Control)

func exit(next_state : State) -> void:
	Game.canvas_manager.clear_layer(JamUtils.layer_ui_menu)
	super.exit(next_state)

func update(delta: float) -> void:
	super.update(delta)

func physics_update(delta: float) -> void:
	super.physics_update(delta)
