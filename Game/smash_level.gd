extends Node3D

@onready var level : Node3D = %Level
@onready var char : Node3D = %Main_character2
@onready var npc1 : Node3D = %npc1
@onready var npc2 : Node3D = %npc2
@onready var npc3 : Node3D = %npc3
@onready var npc4 : Node3D = %npc4

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

const GG_ANIMATIONS := [
	{
		"name": "gg/poyas",
		"weight": 30.0
	},
	{
		"name": "gg/idle",
		"weight": 60.0
	}
]

const NPC_ANIMATIONS := [
	{
		"name": "npc/idle",
		"weight": 90.0
	},
	{
		"name": "npc/dance",
		"weight": 10.0
	}
]


var animation_player : AnimationPlayer = null
var animation_player_char : AnimationPlayer = null
var animation_player_npc1 : AnimationPlayer = null
var animation_player_npc2 : AnimationPlayer = null
var animation_player_npc3 : AnimationPlayer = null
var animation_player_npc4 : AnimationPlayer = null
var _last_animation := ""

func _ready() -> void:
	Game.change_game_state(GameState.MENU)
	var king := level.find_child("King_Animation", true, false)
	animation_player = king.get_node("AnimationPlayer") as AnimationPlayer
	animation_player_char = char.get_node("AnimationPlayer") as AnimationPlayer
	animation_player_npc1 = npc1.get_node("AnimationPlayer") as AnimationPlayer
	animation_player_npc2 = npc2.get_node("AnimationPlayer") as AnimationPlayer
	animation_player_npc3 = npc3.get_node("AnimationPlayer") as AnimationPlayer
	animation_player_npc4 = npc4.get_node("AnimationPlayer") as AnimationPlayer
	
	var animation_hand := load("res://Assets/Characters/King_animation_3.res") as Animation
	var animation_breath1 := load("res://Assets/Characters/King_animation_2.res") as Animation
	var animation_breath0 := load("res://Assets/Characters/King_animation_1.res") as Animation
	var animation_gg_idle := load("res://Assets/Characters/gg_idle.res") as Animation
	var animation_gg_poyas := load("res://Assets/Characters/gg_poyas.res") as Animation
	var animation_npc_idle := load("res://Assets/Characters/npc_idle.res") as Animation
	var animation_npc_dance := load("res://Assets/Characters/npc_dance.res") as Animation
	var animation_npc_beer := load("res://Assets/Characters/npc_beer.res") as Animation
	
	var library := AnimationLibrary.new()
	var library_char := AnimationLibrary.new()
	var library_npc_beer := AnimationLibrary.new()
	var library_npc := AnimationLibrary.new()
	
	library.add_animation("hand", animation_hand)
	library.add_animation("breath1", animation_breath1)
	library.add_animation("breath0", animation_breath0)
	library_char.add_animation("idle", animation_gg_idle)
	library_char.add_animation("poyas", animation_gg_poyas)
	library_npc_beer.add_animation("beer", animation_npc_beer)
	library_npc.add_animation("idle", animation_npc_idle)
	library_npc.add_animation("dance", animation_npc_dance)
	
	animation_player.add_animation_library("hand", library)
	animation_player.play("hand/hand")
	animation_player.animation_finished.connect(_on_animation_finished)

	animation_player_char.add_animation_library("gg", library_char)
	animation_player_char.play("gg/idle")
	animation_player_char.animation_finished.connect(_on_animation_finished_char)
	
	animation_player_npc1.add_animation_library("npc", library_npc_beer)
	animation_player_npc1.play("npc/beer")
	animation_player_npc1.animation_finished.connect(_on_animation_finished_npc_1)
	
	animation_player_npc2.add_animation_library("npc", library_npc)
	animation_player_npc2.play("npc/idle")
	animation_player_npc2.animation_finished.connect(_on_animation_finished_npc_2)
	
	animation_player_npc3.add_animation_library("npc", library_npc)
	animation_player_npc3.play("npc/idle")
	animation_player_npc3.animation_finished.connect(_on_animation_finished_npc_3)
	
	animation_player_npc4.add_animation_library("npc", library_npc)
	animation_player_npc4.play("npc/idle")
	animation_player_npc4.animation_finished.connect(_on_animation_finished_npc_4)
	
func _on_animation_finished(_animation_name: StringName) -> void:
	play_random_animation()

func _on_animation_finished_char(_animation_name: StringName) -> void:
	play_random_animation_char()

func _on_animation_finished_npc_2(_animation_name: StringName) -> void:
	play_random_animation_npc_2()

func _on_animation_finished_npc_3(_animation_name: StringName) -> void:
	play_random_animation_npc_3()

func _on_animation_finished_npc_4(_animation_name: StringName) -> void:
	play_random_animation_npc_4()


func _on_animation_finished_npc_1(_animation_name: StringName) -> void:
	await get_tree().create_timer(3).timeout
	animation_player_npc1.play("npc/beer")

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

func play_random_animation_char() -> void:
	var candidates := GG_ANIMATIONS

	var total := 0.0
	for a in candidates:
		total += a.weight

	var random := randf() * total

	for a in candidates:
		random -= a.weight
		if random <= 0.0:
			_last_animation = a.name
			animation_player_char.play(a.name)
			return

func play_random_animation_npc_2() -> void:
	var candidates := NPC_ANIMATIONS

	var total := 0.0
	for a in candidates:
		total += a.weight

	var random := randf() * total

	for a in candidates:
		random -= a.weight
		if random <= 0.0:
			_last_animation = a.name
			animation_player_npc2.play(a.name)
			return

func play_random_animation_npc_3() -> void:
	var candidates := NPC_ANIMATIONS

	var total := 0.0
	for a in candidates:
		total += a.weight

	var random := randf() * total

	for a in candidates:
		random -= a.weight
		if random <= 0.0:
			_last_animation = a.name
			animation_player_npc3.play(a.name)
			return

func play_random_animation_npc_4() -> void:
	var candidates := NPC_ANIMATIONS

	var total := 0.0
	for a in candidates:
		total += a.weight

	var random := randf() * total

	for a in candidates:
		random -= a.weight
		if random <= 0.0:
			_last_animation = a.name
			animation_player_npc4.play(a.name)
			return
