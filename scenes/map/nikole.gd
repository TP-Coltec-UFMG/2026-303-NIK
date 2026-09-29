class_name Nikole extends Node2D

@export var speed = 30.0

var animation_progress : float = 0
var walking_animation_weight : float = 0

@onready var sprite : Sprite2D = $Path2D/PathFollow2D/Sprite2D
@onready var path_follow : PathFollow2D = $Path2D/PathFollow2D
@onready var path : Path2D = $Path2D
@onready var animated_props = $"../AnimatedProps"

@onready var previous_x: float = 0.0

var can_move : bool = false
var is_moving : bool
@export var current_node : MapNode:
	set(value):
		current_node = value
		changed_node.emit(current_node)

signal changed_node(map_node)

var all_nodes : Array[MapNode] = []

var follower : String = "":
	set(value):
		var props = animated_props if animated_props else get_node_or_null("../AnimatedProps")
		var target_parent = path_follow if path_follow else get_node_or_null("Path2D/PathFollow2D")
		
		if not is_inside_tree() or props == null or target_parent == null:
			follower = value
			return

		if not follower.is_empty():
			var old_node = target_parent.get_node_or_null(follower)
			if old_node:
				old_node.reparent(props)
				old_node.animate = true
				call_prop_move(old_node)

		follower = value

		if not follower.is_empty():
			var new_node = props.get_node_or_null(follower)
			if new_node:
				new_node.reparent(target_parent)
				new_node.animate = false
				follower_node = new_node
		else:
			follower_node = null
var follower_node : Node2D = null
var follower_target : Vector2 = Vector2(0, 0)

func _ready() -> void:
	previous_x = sprite.global_position.x
	sprite.scale = Vector2(1, 1)
	
	var nodes_container = get_node_or_null("../Path/Nodes")
	if nodes_container:
		for node in nodes_container.get_children():
			if node is MapNode:
				all_nodes.append(node)
				
	DialogueController.please_move_nikole.connect(auto_move_to_node)

func move_to_node(target_node: MapNode, target_path: Path2D, instant : bool = false):
	if not can_move: return

	is_moving = true
	
	path.curve = target_path.curve
	
	var is_reversed = false 
	if path.curve.get_point_position(0).distance_to(target_node.position) < 6.7:
		is_reversed = true
		
	var start = 1.0 if is_reversed else 0.0
	var end = 0.0 if is_reversed else 1.0

	var camera = $Path2D/PathFollow2D/Camera2D
	if instant:
		camera.position_smoothing_enabled = false
		path_follow.progress_ratio = end
	else:
		camera.position_smoothing_enabled = true
		path_follow.progress_ratio = start
		
		var distance = target_path.curve.get_baked_length()
		var duration = distance / speed / 10
		
		var tween = create_tween()
		tween.tween_property(path_follow, "progress_ratio", end, duration)
		await tween.finished
	
	current_node = target_node
	is_moving = false

func auto_move_to_node(target: int, _follower: String = "", _follower_target : Vector2 = Vector2.ZERO, instant: bool = false):
	if target < 0 or target >= all_nodes.size():
		return
		
	var target_node = all_nodes[target]
	var queue: Array[MapNode] = [current_node]
	var came_from: Dictionary = { current_node: null }
	var found_target: bool = false
	follower = _follower
	follower_target = _follower_target

	while queue.size() > 0:
		var current = queue.pop_front()

		if current == target_node:
			found_target = true
			break

		var neighbors = [
			{"node": current.node_up, "path": current.path_up},
			{"node": current.node_down, "path": current.path_down},
			{"node": current.node_left, "path": current.path_left},
			{"node": current.node_right, "path": current.path_right}
		]

		for neighbor_data in neighbors:
			var next_node = neighbor_data["node"]
			if next_node != null and not came_from.has(next_node):
				queue.push_back(next_node)
				came_from[next_node] = {
					"previous_node": current,
					"path_to_node": neighbor_data["path"]
				}

	if not found_target:
		return

	var path_sequence: Array = []
	var step = target_node

	while came_from[step] != null:
		var step_data = came_from[step]
		path_sequence.push_front({
			"target_node": step, 
			"path": step_data["path_to_node"]
		})
		step = step_data["previous_node"]

	for move_step in path_sequence:
		await move_to_node(move_step["target_node"], move_step["path"], instant)
	
	follower = ""
	
	DialogueController.move_to_node_finished()

func _unhandled_input(event: InputEvent) -> void:
	if is_moving or current_node == null: 
		return
	
	if event.is_action_pressed("interact"):
		if current_node.can_interact:
			print("iniciando diálogo \"" + current_node.dialogue_id + "\"")
			DialogueController.start_dialogue(current_node.dialogue_id)
		else:
			print("não é possível interact com esse nó")

	if event.is_action_pressed("move_up") and current_node.node_up:
		move_to_node(current_node.node_up, current_node.path_up)
	if event.is_action_pressed("move_down") and current_node.node_down:
		move_to_node(current_node.node_down, current_node.path_down)
	if event.is_action_pressed("move_right") and current_node.node_right:
		move_to_node(current_node.node_right, current_node.path_right)
	if event.is_action_pressed("move_left") and current_node.node_left:
		move_to_node(current_node.node_left, current_node.path_left)

func _process(delta: float) -> void:        
	animate(delta)

func animate(delta : float):
	if sprite.global_position.x < previous_x:
		sprite.scale.x = -1.0
	elif sprite.global_position.x > previous_x:
		sprite.scale.x = 1.0
		
	previous_x = sprite.global_position.x

	walking_animation_weight = lerpf(walking_animation_weight, 1.0 if is_moving else 0.0, delta / .075)

	animation_progress += speed * delta * .035

	
	sprite.rotation = (sin(animation_progress) * 0.1) * walking_animation_weight
	sprite.scale.y = 1.0 - (sin(animation_progress * 2) * .01) * walking_animation_weight - ((1 + sin(animation_progress * .5)) * .01)

	sprite.reset_physics_interpolation()

	var sprite_offset = Vector2(60, 30)
	if follower_node:
		follower_node.rotation = (sin(animation_progress) * 0.1) * walking_animation_weight
		follower_node.scale.y = 1.0 - (sin(animation_progress * 2) * .01) * walking_animation_weight - ((1 + sin(animation_progress * .5)) * .01)
		follower_node.position.y = -sprite_offset.y + (-(1 + sin(animation_progress * 2 - PI / 2)) * 15.25) * walking_animation_weight
		follower_node.position.x = -sprite_offset.x

		follower_node.reset_physics_interpolation()
		sprite.position.y = sprite_offset.y + (-(1 + sin(animation_progress * 2 - PI / 2)) * 15.25) * walking_animation_weight
		sprite.position.x = sprite_offset.x

		follower_node.scale.x = -sprite.scale.x
	else:
		sprite.position.y = (-(1 + sin(animation_progress * 2 - PI / 2)) * 15.25) * walking_animation_weight
		sprite.position.x = 0

func call_prop_move(target_node : Node2D):
	target_node.move_to(follower_target)

func move_sprite(target_position : Vector2, instant : bool = false):
	if instant:
		sprite.position = target_position
		return

	var tween = create_tween()
	tween\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", target_position, 0.75)

	await tween.finished
