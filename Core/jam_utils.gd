class_name JamUtils

# Add constant names here
#region Globals

# Groups:
const group_player := &"Player"
const group_damageable := &"Damageable"
const group_interactable := &"Interactable"

# Common node names:
const nodepath_health := "Health"

# UI layers:
const layer_ui_menu := &"Menu"
const layer_ui_post_process := &"PostProcess"
const layer_ui_info := &"Info"
const layer_ui_hud := &"HUD"

#endregion

#region Nodes

static func find_parent_in_group(child_node : Node, group : StringName) -> Node:
	if not child_node:
		return null
	while child_node:
		if child_node.is_in_group(group):
			return child_node
		child_node = child_node.get_parent()
	return null

#endregion

#region Nodes2D

static func get_unscaled_transform_2d(transform : Transform2D) -> Transform2D:
	return Transform2D(transform.get_rotation(),transform.origin)

static func get_closest_node_2d(point : Vector2, candidates : Array[Node2D]) -> Node2D:
	if candidates.is_empty():
		return null
	var best_item := candidates[0]
	var best_dist := best_item.global_position.distance_to(point)
	for item in candidates:
		var dist := item.global_position.distance_to(point)
		if dist < best_dist:
			best_dist = dist
			best_item = item
	return best_item

#endregion

#region Nodes3D

static func get_unscaled_transform_3d(transform : Transform3D) -> Transform3D:
	return Transform3D(Basis(transform.basis.get_rotation_quaternion()), transform.origin)

static func get_closest_node_3d(point : Vector3, candidates : Array[Node3D]) -> Node3D:
	if candidates.is_empty():
		return null
	var best_item := candidates[0]
	var best_dist := best_item.global_position.distance_to(point)
	for item in candidates:
		var dist := item.global_position.distance_to(point)
		if dist < best_dist:
			best_dist = dist
			best_item = item
	return best_item

#endregion

#region Attributes

## Only searches direct children
static func get_attributes(target : Node) -> Array[Attribute]:
	var result : Array[Attribute] = []
	if target:
		for node in target.get_children():
			if node is Attribute:
				result.append(node as Attribute)
	return result

## Returns first attribute found that matches given tag
static func find_tagged_attribute(target : Node, tag : Attribute.Tag) -> Attribute:
	# TODO: optimize
	var attributes := get_attributes(target)
	for attribute in attributes:
		if attribute.tag == tag:
			return attribute
	return null

#endregion

#region Groups

static func get_shared_groups(node_a : Node, node_b : Node) -> Array[StringName]:
	return get_groups_shared_by_node(node_a, node_b.get_groups())

static func get_groups_shared_by_node(node : Node, groups : Array[StringName]) -> Array[StringName]:
	var result : Array[StringName]
	if not node:
		return []
	for group in groups:
		if node.is_in_group(group):
			result.append(group)
	return result

static func is_node_in_groups(node : Node, groups : Array[StringName]) -> bool:
	if not node:
		return false
	for group in groups:
		if node.is_in_group(group):
			return true
	return false

#endregion

#region Damage

static func get_damageable_from(child_node : Node) -> Node:
	return find_parent_in_group(child_node, group_damageable)

static func get_health_from(child_node : Node) -> Attribute:
	var damageable := get_damageable_from(child_node)
	if not damageable:
		push_warning("Node " + str(child_node) + " is not a child of a Damageable node!")
		return null
	var health := damageable.get_node(nodepath_health) as Attribute
	if not health:
		push_error("Health not found on Damageable node " + str(damageable))
		return null
	return health

static func deal_damage(target : Node, damage : float) -> bool:
	var health := get_health_from(target)
	if not health:
		return false
	if health.value <= 0.0:
		return false
	health.add_instant(-damage)
	return true

#endregion

#region Interactions

const _activatable_getter := &"get_activatable"

static func begin_interaction(instigator : Node, target : Node) -> bool:
	var activatable := get_activatable_from(target)
	if activatable:
		activatable.activate(instigator)
		return true
	return false

static func get_activatable_from(child_node : Node) -> Activatable:
	var interactable := find_interactable_parent(child_node)
	if not interactable:
		push_warning("Node " + str(child_node) + " is not a child of an Interactable node!")
		return null
	if not interactable.has_method(_activatable_getter):
		push_error("Intaractable node " + str(interactable) + " does not implement get_activatable() method")
		return null
	return interactable.get_activatable()

static func find_interactable_parent(child_node : Node) -> Node:
	return find_parent_in_group(child_node, group_interactable)

#endregion

#region Input

static func get_move_input_dir_2d() -> Vector2:
	return Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_backward")

static func get_move_input_dir_3d() -> Vector3:
	var dir_horizontal := get_move_input_dir_2d()
	var axis_vertical := Input.get_axis(&"crouch", &"jump")
	var dir_3d := Vector3(dir_horizontal.x, axis_vertical, dir_horizontal.y)
	return dir_3d

#endregion

#region Random

static func get_random_vector_2d() -> Vector2:
	var result := Vector2.ZERO
	result.x = randfn(0.0, 1.0)
	result.y = randfn(0.0, 1.0)
	result = result.normalized()
	return result

static func get_random_vector_3d() -> Vector3:
	var result := Vector3.ZERO
	result.x = randfn(0.0, 1.0)
	result.y = randfn(0.0, 1.0)
	result.z = randfn(0.0, 1.0)
	result = result.normalized()
	return result

# Only randomizes hue, with fixed value, saturation, and alpha
static func get_random_color(value : float = 1.0, saturation : float = 1.0, alpha : float = 1.0,) -> Color:
	var random_hue := randf()
	return Color.from_hsv(random_hue, saturation, value, alpha)

#endregion
