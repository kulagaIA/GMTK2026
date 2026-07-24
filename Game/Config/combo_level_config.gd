class_name SmashComboLevelConfig
extends Resource

## Upgrade combo to next level after gaining this much points
@export var combo_meter_to_next_level : float = 100.0

## How much of the combo meter is being lost per second
@export var cooling_rate : float = 1.0

## Multiply all points received by this amount
@export var points_multiplier : float = 1.0

# TODO: use this Control for this combo level
#@export var visuals : PackedScene
