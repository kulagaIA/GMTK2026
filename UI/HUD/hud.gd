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

func _process(delta: float) -> void:
	pass

func set_face_texture(texture: Texture2D):
	var face_display := get_node("%FaceDisplay") as TextureRect
	face_display.texture = texture

@onready var stun_screen: Control = %StunScreen

func _on_player_stunned(stunned: bool) -> void:
	stun_screen.visible = stunned

#region PP

@export var hurt_threshold_ratio: float = 0.3
var hurt_threshold: float:
	get:
		return max_health.value * hurt_threshold_ratio

const hurt_effect_scene: PackedScene = preload("uid://puarbl8g8rtt")
var hurt_effect: Vignette = null

func _update_vignette() -> void:
	if not hurt_effect:
		hurt_effect = hurt_effect_scene.instantiate() as Vignette
		Game.canvas_manager.set_layer_content(JamUtils.layer_ui_post_process, hurt_effect)
	hurt_effect.alpha = clampf(1 - health.value / hurt_threshold, 0, 1)

func _remove_vignette() -> void:
	if hurt_effect:
		hurt_effect.queue_free()
		hurt_effect = null

func _on_health_value_changed(attribute : Attribute, new_value : float, old_value : float) -> void:
	if new_value <= hurt_threshold:
		_update_vignette()
	else:
		_remove_vignette()

#endregion
