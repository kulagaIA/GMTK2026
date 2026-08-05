class_name ProgressionScreen
extends Control

#TODO: for debug
@export var purchased: Dictionary[String, ProgressionLeafControl]

signal item_purchased

const game_over_scene: PackedScene = preload("res://UI/GameOver/game_over_screen.tscn")

@onready var point_label: Label = %PointLabel
#@onready var tree: ProgressionTreeControl = %Tree

var points_attribute : Attribute:
	get:
		return Game.player_state.points

var points_available : int:
	get:
		return int(points_attribute.value)

func _ready() -> void:
	update_points()
	#tree.purchase_requested.connect(_on_leaf_purchase_requested)
	Game.tutorial_manager.request_tutorial(Tutorial.Tag.PROGRESSION)

func _on_leaf_purchase_requested(leaf: ProgressionLeafControl) -> void:
	if purchased.has(leaf.name):
		print("already purchased")
	elif leaf.dependent_on != null and not purchased.has(leaf.dependent_on.name):
		print("first you need to purchase %s" % [leaf.dependent_on.name])
	elif points_available < leaf.cost:
		print("not enough points")
	else:
		points_attribute.add(-leaf.cost)
		purchased[leaf.name] = leaf
		item_purchased.emit()
		print("purchased item %s" % [leaf.name])
		for modifier in leaf.modifiers:
			var target_attribute := JamUtils.find_tagged_attribute(Game.player_state, modifier.target)
			assert(target_attribute)
			assert(target_attribute is DynamicAttribute)
			(target_attribute as DynamicAttribute).add_modifier(modifier.mod_info)
		
	point_label.text = "%d" % [Game.player_state.points.value]


func _on_back_pressed() -> void:
	#Game.load_gameplay_scene()
	Game.change_game_state(GameState.GAMEPLAY)

func _on_attribute_upgraded(attribute: Attribute.Tag) -> void:
	update_info()

@onready var health_upgrader: AttributeLevelUpgrader = %HealthUpgrader
@onready var damage_upgrader: AttributeLevelUpgrader = %DamageUpgrader
@onready var timer_upgrader: AttributeLevelUpgrader = %TimerUpgrader
@onready var crit_chance_upgrader: AttributeLevelUpgrader = %CritChanceUpgrader
@onready var crit_multiplier_upgrader: AttributeLevelUpgrader = %CritMultiplierUpgrader
@onready var pivo_charge_per_hit: AttributeLevelUpgrader = %PivoChargePerHit

func update_points() -> void:
	point_label.text = "%d" % [points_available]

func update_info() -> void:
	update_points()
	health_upgrader.update_info()
	damage_upgrader.update_info()
	timer_upgrader.update_info()
	crit_chance_upgrader.update_info()
	crit_multiplier_upgrader.update_info()
	pivo_charge_per_hit.update_info()
