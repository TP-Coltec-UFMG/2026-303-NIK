class_name Nikole extends Node2D

@export var speed = 30.0

var animation_progress : float = 0
var walking_animation_weight : float = 0

@onready var sprite : Sprite2D = $Path2D/PathFollow2D/Sprite2D
@onready var path_follow : PathFollow2D = $Path2D/PathFollow2D
@onready var path : Path2D = $Path2D

@onready var previous_x = sprite.global_position.x;

var is_moving : bool
@export var current_node : MapNode:
	set(value):
		current_node = value
		changed_node.emit(current_node)

signal changed_node(map_node)

var all_nodes : Array[MapNode] = []

func _ready() -> void:
	for node in $"../Path/Nodes".get_children():
		all_nodes.append(node as MapNode)
	DialogueController.please_move_nikole.connect(auto_move_to_node)

func move_to_node(target_node: MapNode, target_path: Path2D, instant : bool = false):
	is_moving = true
	
	path.curve = target_path.curve
	
	var is_reversed = false 
	#if path.curve.get_point_position(0).distance_to(current_node.position) > 6.7: # se estiver longe do primeiro ponto, é pq ta vindo do fim
	#	is_reversed = true

	if path.curve.get_point_position(0).distance_to(target_node.position) < 6.7:
		is_reversed = true
		
	var start = 1.0 if is_reversed else 0.0
	var end = 0.0 if is_reversed else 1.0

	if instant:
		$Path2D/PathFollow2D/Camera2D.position_smoothing_enabled = false
		path_follow.progress_ratio = end
	else:
		$Path2D/PathFollow2D/Camera2D.position_smoothing_enabled = true
		path_follow.progress_ratio = start
		
		var distance = target_path.curve.get_baked_length()
		var duration = distance / speed / 10
		
		var tween = create_tween()
		tween.tween_property(path_follow, "progress_ratio", end, duration)
		await tween.finished
	
	current_node = target_node
	is_moving = false

func auto_move_to_node(target: int, instant: bool = false): # SÓ DEVE SER CHAMADO PELO CONTROLADOR DE DIÁLOGO!!! (eu acho né kkk)
	var target_node = all_nodes[target]
	var queue: Array[MapNode] = [current_node]
	var came_from: Dictionary = { current_node: null }
	var found_target: bool = false

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
	
	DialogueController.move_to_node_finished()

func _unhandled_input(event):
	if is_moving: return
	
	if event.is_action_pressed("interact") :
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
	sprite.scale.x = -1.0 if (sprite.global_position.x < previous_x) else 1.0 if (sprite.global_position.x > previous_x) else sprite.scale.x
	previous_x = sprite.global_position.x

	walking_animation_weight = lerpf(walking_animation_weight, 1 if is_moving else 0, delta / .075)

	animation_progress += speed * delta * .035
	
	sprite.rotation = (sin(animation_progress) * 0.1) * walking_animation_weight + (sin(animation_progress / 4) * 0.0)
	sprite.scale.y = 1 - (sin(animation_progress * 2) * .01) * walking_animation_weight + -((1 + sin(animation_progress * .5)) * .01)
	sprite.position.y = 0 + (-(1 + sin(animation_progress * 2 - PI / 2)) * 15.25) * walking_animation_weight

	sprite.reset_physics_interpolation()
