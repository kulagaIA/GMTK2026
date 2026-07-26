class_name HitInfo
extends RefCounted

var attacker: Node
var target: Node

var damage_to_target_base : float
var damage_to_attacker_base : float

var damage_to_target_modified : float
var damage_to_attacker_modified : float

var velocity: float
var amplitude: float

var target_smashed : bool = false

var attacker_crit : bool = false
var attacker_crit_multiplier : float = 1.0
var attacker_stunned : bool = false
