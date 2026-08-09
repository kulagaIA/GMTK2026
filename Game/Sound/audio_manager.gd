extends Node

const MASTER_BUS = "Master"
const MUSIC_BUS = "Music"
const SFX_BUS = "SFX"
const UI_BUS = "UI"

enum BusType {
	MASTER_BUS,
	MUSIC_BUS,
	SFX_BUS,
	UI_BUS
}

var bus_types = {
	MASTER_BUS: "Master",
	MUSIC_BUS: "Music",
	SFX_BUS: "SFX",
	UI_BUS: "UI"
}

@export var global_sound: GlobalSoundsResource = load("res://Data/Audio/global_sounds.tres")

func play_sound(sound, source: Node, bus_type: BusType, pitch_randomize: Vector2 = Vector2(0.0, 0.0), volume: float = 0.0):
	var player = AudioStreamPlayer3D.new()
	player.bus = bus_types[SFX_BUS]
	
	if sound is Array[AudioStream]:
		player.stream = sound.pick_random()
	elif sound is String:
		player.stream = load(sound)
	else:
		player.stream = sound
		
	if pitch_randomize.x != 0.0 and pitch_randomize.y != 0.0:
		var pitch_modulation = 1.0 + range(pitch_randomize.x, pitch_randomize.y).pick_random() / 100.0
		pitch_modulation = clamp(pitch_modulation, 0.1, 2.0)
		player.pitch_scale = pitch_modulation
		
	player.volume_db += volume
	
	source.add_child(player)
	player.play()
	player.connect("finished", Callable(player, "queue_free"))
