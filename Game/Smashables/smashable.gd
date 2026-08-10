class_name Smashable
extends Node3D

@export var data : SmashableResource = null

@onready var max_health: SimpleAttribute = %MaxHealth
@onready var health: SimpleAttribute = %Health
@onready var damage: SimpleAttribute = %Damage
@onready var reward: SimpleAttribute = %Reward

@onready var sparks: GPUParticles3D = %BombSparks
@onready var bomb_timer: Timer = $BombTimer

signal destroyed(target: Smashable)
var _destroyed : bool = false

@onready var _view: SmashableView = %SmashableView
@onready var _mesh: MeshInstance3D = _view.mesh

@onready var _sound_player: SmashableSoundPlayer = %SmashableSoundPlayer
@onready var audio_stream_player_3d: AudioStreamPlayer3D = $AudioStreamPlayer3D

enum DamageStage {
	INTACT,
	DAMAGED,
	BROKEN
}

var _stage := DamageStage.INTACT

func _ready() -> void:
	apply_stats(data)

func _process(delta: float) -> void:
	pass

func apply_stats(stats: SmashableResource) -> void:
	assert(stats)
	max_health.set_value(stats.health)
	health.max_value = stats.health
	health.set_value(stats.health)
	damage.set_value(stats.damage)
	reward.set_value(stats.reward)
	_view.configure(stats)
	_sound_player.configure(stats)
	_sound_player.play_roll()
	sparks.visible = stats.is_a_bomb()
	if stats.is_a_bomb():
		_view.rotate_y(deg_to_rad(45))
		sparks.global_position = _view.bomb_sparks_root.global_position
		audio_stream_player_3d.play()

func start_bomb() -> void:
	if data.is_a_bomb():
		#sparks.visible = true
		bomb_timer.start(Game.starting_player_stats.bomb_fuse_seconds)
		

func get_base_damage() -> float:
	#return damage.value
	return Game.player_state.stamina_decay.value

# HACK: this is hard-coded to be damage to attacker, called before PlayerState
func modify_hit(info: HitInfo) -> void:
	info.damage_to_attacker_modified = info.damage_to_attacker_base

func apply_damage(amount: float) -> void:
	take_damage(amount)

func _on_hit_occurred(info: HitInfo) -> void:
	if info.target == self:
		_view.play_hit()
		var hit_sound_info: HitSoundInfo = _construct_hit_sound_info(info)
		_sound_player.play_hit(hit_sound_info)
		_update_damage_stage()

func _construct_hit_sound_info(info: HitInfo) -> HitSoundInfo:
	var hit_sound_info = HitSoundInfo.new()
	if info.attacker_crit == true:
		hit_sound_info.is_crit = true
	if Game.player_state.max_stamina.value > 100:
		hit_sound_info.hit_type = SmashableSoundPlayer.HitSoundType.METAL
	return hit_sound_info

func take_damage(amount: float) -> void:
	health.add(-amount)

func _on_health_value_changed(attribute: Attribute, new_value: float, old_value: float) -> void:
	if not _destroyed:
		#print("Smashable HP left: %f" % [new_value])
		if new_value <= 0.0:
			_destroyed = true
			if not data.is_a_bomb() or not bomb_timer.is_stopped():
				_sound_player.play_destroy()
				sparks.visible = false
				_view.play_destroy()
			destroyed.emit(self)

func _update_damage_stage() -> void:
	var ratio := health.value / max_health.value

	if ratio <= 0.0:
		if _stage != DamageStage.BROKEN:
			_stage = DamageStage.BROKEN
			_mesh.mesh = data.broken_mesh
	elif ratio <= 0.5:
		if _stage != DamageStage.DAMAGED:
			_stage = DamageStage.DAMAGED
			_mesh.mesh = data.damaged_mesh
	else:
		if _stage != DamageStage.INTACT:
			_stage = DamageStage.INTACT
			_mesh.mesh = data.intact_mesh


func _on_bomb_timer_timeout() -> void:
	take_damage(100)
	sparks.visible = false
	_view.play_hit()
	destroyed.emit(self)
	audio_stream_player_3d.stop()
