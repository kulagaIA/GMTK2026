class_name ProgressionScreen
extends Control

#TODO: for debug
@export var purchased: Dictionary[String, Item]

signal item_purchased

const arrow : PackedScene = preload("res://UI/Progression/arrow.tscn")
const game_over_scene: PackedScene = preload("res://UI/GameOver/game_over_screen.tscn")

@onready var point_label: Label = %PointLabel

func _ready() -> void:
	point_label.text = "Points available: %d" % [Game.player_state.points.value]
	for item in %Items.get_children():
		if item is Item:
			item.connect("trying_to_purchase", _on_item_trying_to_purchase)
			if item.dependent_on != null:
				var start: Vector2 = item.dependent_on.global_position + item.dependent_on.size / 2
				var end: Vector2 = item.global_position + item.size / 2
				var arr: Control = arrow.instantiate()
				var angle: float = start.angle_to_point(end)
				item.dependent_on.add_child(arr)
				arr.position = Vector2(arr.get_parent().size.x / 2, -arr.get_parent().size.y / 2 + arr.size.y / 15)
				arr.position += Vector2(cos(angle), sin(angle)) * arr.get_parent().size.x / 2
				arr.size.x = start.distance_to(end) * 10 - 1280
				arr.rotation = angle

func _on_item_trying_to_purchase(item: Item) -> void:
	if purchased.has(item.name):
		print("already purchased")
	elif item.dependent_on != null and not purchased.has(item.dependent_on.name):
		print("first you need to purchase %s" % [item.dependent_on.name])
	elif Game.player_state.points.value < item.cost:
		print("not enough points")
	else:
		Game.player_state.points.add(-item.cost)
		purchased[item.name] = item
		item_purchased.emit()
		print("purchased item %s" % [item.name])
		for modifier in item.modifiers:
			match modifier.target:
				ModifierInfo.TargetType.DAMAGE:
					Game.player_state.damage.add_modifier(modifier.mod_info)
				ModifierInfo.TargetType.MAX_HEALTH:
					Game.player_state.max_health.add_modifier(modifier.mod_info)
				ModifierInfo.TargetType.SPEED:
					Game.player_state.sensitivity.add_modifier(modifier.mod_info)
		
	point_label.text = "Points available: %d" % [Game.player_state.points.value]


func _on_back_pressed() -> void:
	Game.load_gameplay_scene()
