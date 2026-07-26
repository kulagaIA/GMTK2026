extends Node3D

@onready var level : Node3D = %Level

const ANIMATIONS := [
	{
		"name": "hand/hand",
		"weight": 10.0
	},
	{
		"name": "hand/breath1",
		"weight": 60.0
	},
	{
		"name": "hand/breath0",
		"weight": 30.0
	}
]

var animation_player : AnimationPlayer = null
var _last_animation := ""

func _ready() -> void:
	Game.change_game_state(GameState.MENU)
	var king := level.find_child("King_Animation", true, false)
	animation_player = king.get_node("AnimationPlayer") as AnimationPlayer
	var animation_hand := load("res://Assets/Characters/King_animation_3.res") as Animation
	var animation_breath1 := load("res://Assets/Characters/King_animation_2.res") as Animation
	var animation_breath0 := load("res://Assets/Characters/King_animation_1.res") as Animation
	var library := AnimationLibrary.new()
	library.add_animation("hand", animation_hand)
	library.add_animation("breath1", animation_breath1)
	library.add_animation("breath0", animation_breath0)
	animation_player.add_animation_library("hand", library)
	animation_player.play("hand/hand")
	animation_player.animation_finished.connect(_on_animation_finished)
	
	
func _on_animation_finished(_animation_name: StringName) -> void:
	play_random_animation()

func play_random_animation() -> void:
	var candidates := ANIMATIONS.filter(func(a): return a.name != _last_animation)

	var total := 0.0
	for a in candidates:
		total += a.weight

	var random := randf() * total

	for a in candidates:
		random -= a.weight
		if random <= 0.0:
			_last_animation = a.name
			animation_player.play(a.name)
			return
