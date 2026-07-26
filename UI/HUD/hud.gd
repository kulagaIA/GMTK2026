class_name HUD
extends Control


func _ready() -> void:
	Game.player.stun_status_changed.connect(_on_player_stunned)
	var texture := Game.player.face_renderer.subviewport.get_texture() as ViewportTexture
	set_face_texture(texture)
	Game.player_state.health.value_changed.connect(_on_health_value_changed)

func _process(delta: float) -> void:
	pass

func set_face_texture(texture: Texture2D):
	var face_display := get_node("%FaceDisplay") as TextureRect
	face_display.texture = texture

@onready var stun_screen: Control = %StunScreen

func _on_player_stunned(stunned: bool) -> void:
	stun_screen.visible = stunned

#region PP

@export var vignette_threshold: float = 60
@export var vignette_color: Color = Color.DARK_RED
const vignette_scene: PackedScene = preload("res://UI/PP/vignette.tscn")
var vignette: Vignette = null

func _update_vignette() -> void:
	if vignette == null:
		vignette = vignette_scene.instantiate() as Vignette
		add_child(vignette)
	vignette.update(clampf(1 - Game.player_state.health.value / vignette_threshold, 0, 1), vignette_color)

func _on_health_value_changed(attribute : Attribute, new_value : float, old_value : float) -> void:
	if new_value <= vignette_threshold:
		_update_vignette()

#endregion
