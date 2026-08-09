class_name GameplayGameState
extends GameState

@export var autopause_delay : float = 0.5
var _uncaptured_time : float = 0.0
@export var countdown_scene : PackedScene


func enter(prev_state : State) -> void:
	super.enter(prev_state)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_uncaptured_time = 0.0
	assert(Game.gameplay)
	var camera := SmashCamera.get_active()
	var target_camera := SmashCamera.get_by_tag(SmashCamera.Tag.GAMEPLAY)
	assert(camera)
	assert(target_camera)
	await camera.fly_and_reparent(target_camera, 2.5)
	
	Game.gameplay.prepare_gameplay()
	Game.player.mouse_controls_enabled = true
	var countdown := countdown_scene.instantiate() as Control
	Game.canvas_manager.push_content_to_layer(JamUtils.layer_ui_menu, countdown)
	await countdown.tree_exited
	#if not Game.game_state_machine.current_state is GameplayGameState:
		#return
	Game.gameplay.hit_occurred.connect(Game.player_state._on_hit_occurred)
	Game.player_state.stamina.value_changed.connect(Game.player._on_health_value_changed)
	Game.gameplay.start_gameplay()
	_show_hud()

func exit(next_state : State) -> void:
	_hide_hud()
	Game.canvas_manager.clear_layer(JamUtils.layer_ui_post_process)
	Game.gameplay.hit_occurred.disconnect(Game.player_state._on_hit_occurred)
	Game.player_state.stamina.value_changed.disconnect(Game.player._on_health_value_changed)
	Game.gameplay.stop_gameplay()
	super.exit(next_state)

func update(delta: float) -> void:
	super.update(delta)
	if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED and not get_tree().paused and Game.player._gameplay_started:
		_uncaptured_time += delta
		if _uncaptured_time > autopause_delay:
			_uncaptured_time = 0.0
			Game.open_pause_menu()

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
