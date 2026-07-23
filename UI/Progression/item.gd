class_name Item
extends Control

@export var icon: Texture2D
@export var dependent_on: Item
@export var cost: int
@export var modifiers: Array[ModifierInfo] = []

var is_purchased: bool

signal trying_to_purchase(source: Item)

func _ready() -> void:
	%Icon.texture = icon
	pass

func _on_button_pressed() -> void:
	trying_to_purchase.emit(self)
