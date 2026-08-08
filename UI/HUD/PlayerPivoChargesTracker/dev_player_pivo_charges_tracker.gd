extends Control

@export var progress := 0.0
@export var thickness := 30.0
@export var color := Color.YELLOW
@export var background_color := Color(0.2,0.2,0.2,0.5)

@onready var icon : TextureRect = %PivoIcon
@onready var counter : Label = %PivoChargesCounter

func _draw():
	var rect = icon.get_rect()
	var center = rect.position + rect.size * 0.5
	var radius = min(rect.size.x, rect.size.y) * 0.5 + thickness
	draw_arc(
		center,
		radius,
		0,
		TAU,
		64,
		background_color,
		thickness
	)
	draw_arc(
		center,
		radius,
		-PI/2,
		-PI/2 + TAU * progress,
		64,
		color,
		thickness
	)

func _ready() -> void:
	if Game.player_state:
		Game.player_state.pivo_charges.value_changed.connect(_on_player_pivo_charges_value_changed)
	show_value(Game.player_state.pivo_charges.value)

func _exit_tree() -> void:
	if Game.player_state:
		Game.player_state.pivo_charges.value_changed.disconnect(_on_player_pivo_charges_value_changed)

func _on_player_pivo_charges_value_changed(attribute: Attribute, new_value: float, old_value: float) -> void:
	show_value(new_value)

func show_value(value : float) -> void:
	progress = fmod(value, 1.0)
	queue_redraw()
	counter.text = str(int(value)) 
