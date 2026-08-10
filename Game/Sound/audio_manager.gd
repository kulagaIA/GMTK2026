extends Node

enum BusType {
	MASTER_BUS,
	MUSIC_BUS,
	SFX_BUS,
	UI_BUS
}

const BUS_TYPES = [
	"Master",
	"Music",
	"SFX",
	"UI"
]

@export var global_sound: GlobalSoundsResource = load("res://Data/Audio/global_sounds.tres")

func play_sound(sound, source: Node, bus_type: BusType, pitch_randomize: Vector2 = Vector2(0.0, 0.0), volume: float = 0.0):
	var player = AudioStreamPlayer3D.new()
	player.bus = BUS_TYPES[bus_type]
	
	if sound is Array[AudioStream]:
		player.stream = sound.pick_random()
	elif sound is String:
		player.stream = load(sound)
	else:
		player.stream = sound
		
	if pitch_randomize.x != 0.0 and pitch_randomize.y != 0.0:
		if pitch_randomize.y > pitch_randomize.x:
			var pitch_modulation = 1.0 + range(pitch_randomize.x, pitch_randomize.y).pick_random() / 100.0
			pitch_modulation = clamp(pitch_modulation, 0.1, 2.0)
			player.pitch_scale = pitch_modulation
		else:
			player.pitch_scale = 1.0 + pitch_randomize.x
		
	player.volume_db += volume
	
	source.add_child(player)
	player.play()
	player.connect("finished", Callable(player, "queue_free"))


func set_low_pass_filter(bus_type: BusType, cutoff_hz: float, duration: float = 1.0):
	var bus_name: String = BUS_TYPES[bus_type]
	var bus_index := AudioServer.get_bus_index(bus_name)
	
	if bus_index == -1:
		return
	
	var effect := AudioServer.get_bus_effect(bus_index, 0) as AudioEffectLowPassFilter
	
	if effect == null:
		return
	
	var tween := create_tween()
	tween.tween_property(effect, "cutoff_hz", cutoff_hz, duration)


func set_reverb(bus_type: BusType, wet: float, duration: float = 1.0):
	var bus_name: String = BUS_TYPES[bus_type]
	var bus_index := AudioServer.get_bus_index(bus_name)
	
	if bus_index == -1:
		return
	
	var effect := AudioServer.get_bus_effect(bus_index, 1) as AudioEffectReverb
	
	if effect == null:
		return
	
	var tween := create_tween()
	tween.tween_property(effect, "wet", wet, duration)
