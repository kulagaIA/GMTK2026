class_name GameplayGameState
extends GameState


func enter(prev_state : State) -> void:
	super.enter(prev_state)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_show_hud()
	assert(Game.gameplay)
	Game.gameplay.hit_occurred.connect(Game.player_state._on_hit_occurred)
	Game.player_state.health.value_changed.connect(Game.player._on_health_value_changed)
	Game.gameplay.restart_gameplay()

func exit(next_state : State) -> void:
	_hide_hud()
	Game.gameplay.hit_occurred.disconnect(Game.player_state._on_hit_occurred)
	Game.player_state.health.value_changed.disconnect(Game.player._on_health_value_changed)
	await Game.player.unstun()
	super.exit(next_state)

func update(delta: float) -> void:
	super.update(delta)

func physics_update(delta: float) -> void:
	super.physics_update(delta)

#region HUD

@export var hud_scene : PackedScene

func _show_hud() -> void:
	if hud_scene:
		var hud := hud_scene.instantiate() as Control
		Game.canvas_manager.set_layer_content(JamUtils.layer_ui_hud, hud)

func _hide_hud() -> void:
	Game.canvas_manager.clear_layer(JamUtils.layer_ui_hud)

#endregion
