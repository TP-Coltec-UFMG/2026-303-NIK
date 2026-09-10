class_name NikoleMaze extends Node2D

@onready var maze : Maze = get_tree().current_scene as Maze
@onready var sprite : Sprite2D = $Sprite2D

const speed = 20.0

var animation_progress : float = 0
var walking_animation_weight : float = 0

var current_pos : Vector2i
var target_pos : Vector2

var is_moving : bool = false

var x_direction = 1

var targets : Array[Vector2] = [Vector2(), Vector2(), Vector2()]
@export var arrow_sprites : Array[Texture2D]
var arrow_orbit_radius : float = 300
var arrow_orbit_offset : Vector2 = Vector2(0, -80)

func _ready() -> void:
	current_pos = Vector2i(1, 1)
	$Camera2D.position_smoothing_enabled = false
	position = (Vector2(0.5, 0.8) + Vector2(current_pos)) * maze.tile_scale
	target_pos = position

func _unhandled_input(event: InputEvent) -> void:
	$Camera2D.position_smoothing_enabled = true
	if event.is_action_pressed("move_up") or event.is_action_pressed("ui_up"):
		move_to_tile(current_pos.x, current_pos.y - 1)

	if event.is_action_pressed("move_right") or event.is_action_pressed("ui_right"):
		x_direction = 1
		move_to_tile(current_pos.x + 1, current_pos.y)

	if event.is_action_pressed("move_down") or event.is_action_pressed("ui_down"):
		move_to_tile(current_pos.x, current_pos.y + 1)

	if event.is_action_pressed("move_left") or event.is_action_pressed("ui_left"):
		x_direction = -1
		move_to_tile(current_pos.x - 1, current_pos.y)

func _draw() -> void:
	if not maze.dropped_francisco: draw_arrow(0)
	if not maze.dropped_luis: draw_arrow(1)
	if not maze.dropped_flavia: draw_arrow(2)

func draw_arrow(target : int):
	var deg = (targets[target] - position).angle()
	var arrow_position = Vector2.from_angle(deg) * (arrow_orbit_radius - (sin(animation_progress / 5) * arrow_orbit_radius * 0.05)) + arrow_orbit_offset

	# print(deg)

	var texture = arrow_sprites[target]
	var texture_size = texture.get_size()

	var rect = Rect2(-texture_size / 2, texture_size)
	draw_set_transform(arrow_position, deg)
	draw_texture_rect(arrow_sprites[target], rect, false)
	draw_set_transform(Vector2(), 0)

func move_to_tile(x : int, y : int, instant : bool = false):
	if maze.is_walkable(x, y):
		current_pos.x = x
		current_pos.y = y

		target_pos.x = (0.5 + current_pos.x) * maze.tile_scale 
		target_pos.y = (0.8 + current_pos.y) * maze.tile_scale 
		
		maze.check_kid_pickup(x, y)
		maze.check_kid_dropout(x, y)
		maze.check_end_game(x, y)

		if instant:
			position = target_pos
		else:
			is_moving = true
			walking_animation_weight = 1

func _process(delta: float) -> void:
	# funny()	
	if is_moving and position.distance_to(target_pos) < 5:
		is_moving = false
		position = target_pos
	else:
		position = lerp(position, target_pos, delta / 0.1)
	queue_redraw()

	animate(delta)

func funny():
	var r = randi_range(1, 4)
	if r == 1:
		move_to_tile(current_pos.x, current_pos.y - 1)

	if r == 2:
		x_direction = 1
		move_to_tile(current_pos.x + 1, current_pos.y)

	if r == 3:
		move_to_tile(current_pos.x, current_pos.y + 1)

	if r == 4:
		x_direction = -1
		move_to_tile(current_pos.x - 1, current_pos.y)

func animate(delta : float):
	sprite.scale.x = x_direction

	walking_animation_weight = lerpf(walking_animation_weight, 0, delta / 0.2)

	animation_progress += speed * delta * 1
	
	sprite.rotation = (sin(animation_progress) * 0.1) * walking_animation_weight + (sin(animation_progress / 4) * 0.01)
	sprite.scale.y = 1 - (sin(animation_progress * 2) * .01) * walking_animation_weight + -((1 + sin(animation_progress * .5)) * .01)
	sprite.position.y = 0 + (-(1 + sin(animation_progress * 2 - PI / 2)) * 10.25) * walking_animation_weight

	sprite.reset_physics_interpolation()
