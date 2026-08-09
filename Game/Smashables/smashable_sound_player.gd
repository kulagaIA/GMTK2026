class_name SmashableSoundPlayer
extends Node

enum HitSoundType {
	NORMAL,
	METAL
}

@export var min_pitch_scale := 0.96
@export var max_pitch_scale := 1.04

@onready var _hit_effects_player: AudioStreamPlayer3D = %HitEffectsPlayer
@onready var _crit_effects_player: AudioStreamPlayer = %CritEffectsPlayer

var _normal_hits: Array[AudioStream]
var _metal_hits: Array[AudioStream]
var _crit_hits: Array[AudioStream]
var _destroy: Array[AudioStream]
var _roll: Array[AudioStream]

var _last_stream: AudioStream


func configure(data: SmashableResource) -> void:
	assert(data)

	_normal_hits = data.normal_hits
	_metal_hits = data.metal_hits
	_crit_hits = data.crit_hits
	_destroy = data.destroy
	_roll = data.roll


func play_hit(sound_info: HitSoundInfo) -> void:
	var sound_type = sound_info.hit_type
	if sound_info.is_crit:
		AudioManager.play_sound(_crit_hits, get_parent(), AudioManager.BusType.SFX_BUS, Vector2(0.0, 0.0), 24.0)
	if sound_type == HitSoundType.METAL:
			AudioManager.play_sound(_metal_hits, get_parent(), AudioManager.BusType.SFX_BUS, Vector2(-20, 25))
			
	AudioManager.play_sound(_normal_hits, get_parent(), AudioManager.BusType.SFX_BUS, Vector2(-25, 25))


func play_roll() -> void:
	AudioManager.play_sound(_roll, get_parent(), AudioManager.BusType.SFX_BUS, Vector2(25.0, 45.0), 24.0)

func play_destroy() -> void:
	AudioManager.play_sound(AudioManager.global_sound.crowd_claps, self, AudioManager.BusType.SFX_BUS, Vector2(-10.0, 10.0), -10.0)
	AudioManager.play_sound(AudioManager.global_sound.crowd_cheers, self, AudioManager.BusType.SFX_BUS, Vector2(-10.0, 10.0), -10.0)
	AudioManager.play_sound(AudioManager.global_sound.crowd_wow, self, AudioManager.BusType.SFX_BUS, Vector2(-30.0, 0.0))
	AudioManager.play_sound(_destroy, get_parent(), AudioManager.BusType.SFX_BUS, Vector2(0.0, 25.0), 24.0)


func _play_random(player: Node, streams: Array[AudioStream]) -> void:
	if streams.is_empty():
		return

	assert(
		player is AudioStreamPlayer
		or player is AudioStreamPlayer2D
		or player is AudioStreamPlayer3D
	)
	var stream := _pick_random(streams)

	player.stop()
	player.stream = stream
	player.pitch_scale = randf_range(min_pitch_scale, max_pitch_scale)
	player.play()

func _pick_random(streams: Array[AudioStream]) -> AudioStream:
	if streams.size() == 1:
		_last_stream = streams[0]
		return streams[0]

	var stream: AudioStream

	while true:
		stream = streams[randi() % streams.size()]
		if stream != _last_stream:
			break

	_last_stream = stream
	return stream
