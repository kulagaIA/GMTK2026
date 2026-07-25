class_name HUD
extends Control

@onready var dev_smashables_queue_tracker: DevSmashableQueueTracker = %DevSmashablesQueueTracker
func _ready() -> void:
	dev_smashables_queue_tracker.set_number_to_display(Game.gameplay.smashables.size())
	Game.player.stun_status_changed.connect(_on_player_stunned)
	var texture := Game.player.face_renderer.get_texture() as ViewportTexture
	set_face_texture(texture)


func _process(delta: float) -> void:
	pass

func set_face_texture(texture: Texture2D):
	var face_display := get_node("%FaceDisplay") as TextureRect
	face_display.texture = texture

@onready var stun_screen: Control = %StunScreen

func _on_player_stunned(stunned: bool) -> void:
	stun_screen.visible = stunned
