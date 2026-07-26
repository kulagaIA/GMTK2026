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

var _last_stream: AudioStream


func configure(data: SmashableResource) -> void:
	assert(data)

	_normal_hits = data.normal_hits
	_metal_hits = data.metal_hits
	_crit_hits = data.crit_hits
	_destroy = data.destroy


func play_hit(sound_info: HitSoundInfo) -> void:
	var sound_type = sound_info.hit_type
	if sound_info.is_crit:
		_play_random(_crit_effects_player, _crit_hits)
	match sound_type:
		HitSoundType.NORMAL:
			_play_random(_hit_effects_player, _normal_hits)
		HitSoundType.METAL:
			_play_random(_hit_effects_player, _metal_hits)


func play_destroy(sound_info: HitSoundInfo) -> void:
	if sound_info.is_crit:
		_play_random(_crit_effects_player, _crit_hits)
	_play_random(_hit_effects_player, _destroy)


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
