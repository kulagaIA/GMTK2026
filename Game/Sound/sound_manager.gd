class_name SoundManager
extends Node

@onready var drums := %Drums
@onready var melody := %Melody
@export var melody_volume_adjustment_time: float = 3.0
var melody_volume_target: float = 0.0
var master_volume: float = 1.0

signal master_volume_changed(new_volume: float)

func _process(delta: float) -> void:
	if melody.volume_linear != melody_volume_target:
		var speed: float = master_volume / melody_volume_adjustment_time
		if melody_volume_target < melody.volume_linear:
			melody.volume_linear -= delta * speed
		else:
			melody.volume_linear += delta * speed
		melody.volume_linear = clamp(melody.volume_linear, 0.0, master_volume)
		

func _on_game_state_machine_state_changed(old_state: State, new_state: State) -> void:
	if new_state is not GameState:
		return
	match new_state.name:
		"MainMenu", "RoundOver", "Progression", "Victory":
			melody_volume_target = 0.0
		"Gameplay":
			melody_volume_target = master_volume

func change_master_volume(new_volume: float) -> void:
	master_volume = new_volume
	master_volume_changed.emit(new_volume)
