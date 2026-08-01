class_name HUD
extends Control

var health : Attribute:
	get:
		return Game.player_state.health

var max_health : Attribute:
	get:
		return Game.player_state.max_health

func _ready() -> void:
	Game.player.stun_status_changed.connect(_on_player_stunned)
	var texture := Game.player.face_renderer.subviewport.get_texture() as ViewportTexture
	set_face_texture(texture)
	health.value_changed.connect(_on_health_value_changed)
	Game.player_state.pivo.state_changed.connect(_on_pivo_state_changed)

func _process(delta: float) -> void:
	pass

@onready var face_display: TextureRect = %FaceDisplay

func set_face_texture(texture: Texture2D):
	face_display.texture = texture

@onready var post_process_layer: CanvasLayer = %PostProcessLayer

#region PP_Stun

const stun_effect_scene = preload("uid://bm3awdi33xxvt")
var stun_effect : Control = null

func _on_player_stunned(stunned: bool) -> void:
	if stunned:
		_show_stun()
	else:
		_hide_stun()

func _show_stun() -> void:
	if not stun_effect:
		stun_effect = stun_effect_scene.instantiate() as Control
		Game.canvas_manager._push_content_to_layer(post_process_layer, stun_effect)

func _hide_stun() -> void:
	if stun_effect:
		stun_effect.queue_free()
		stun_effect = null

#endregion

#region PP_Hurt

@export var hurt_threshold_ratio: float = 0.3
var hurt_threshold: float:
	get:
		return max_health.value * hurt_threshold_ratio

const hurt_effect_scene: PackedScene = preload("uid://puarbl8g8rtt")
var hurt_effect: Vignette = null

func _update_hurt() -> void:
	#if beer_active:
		#_hide_hurt()
		#return
	if health.value <= hurt_threshold:
		_show_hurt()
	else:
		_hide_hurt()
	if hurt_effect:
		hurt_effect.alpha = clampf(1 - health.value / hurt_threshold, 0, 1)

func _show_hurt() -> void:
	if not hurt_effect:
		hurt_effect = hurt_effect_scene.instantiate() as Vignette
		Game.canvas_manager._push_content_to_layer(post_process_layer, hurt_effect)

func _hide_hurt() -> void:
	if hurt_effect:
		hurt_effect.queue_free()
		hurt_effect = null

func _on_health_value_changed(attribute : Attribute, new_value : float, old_value : float) -> void:
	_update_hurt()

#endregion

#region PP_Beer

const beer_effect_scene: PackedScene = preload("uid://ch4beou2s2owh")
var beer_effect: Control = null
var beer_active : bool = false

func _on_pivo_state_changed(new_state : Ability.State) -> void:
	beer_active = new_state == Ability.State.ACTIVE
	if beer_active:
		_show_pivo()
	else:
		_hide_pivo()
	#_update_hurt()

func _show_pivo() -> void:
	if not beer_effect:
		beer_effect = beer_effect_scene.instantiate() as Control
		Game.canvas_manager._push_content_to_layer(post_process_layer, beer_effect)

func _hide_pivo() -> void:
	if beer_effect:
		beer_effect.queue_free()
		beer_effect = null

#endregion
