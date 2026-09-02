extends Node2D

@export var maze: Maze
@onready var sprite : Sprite2D = $Sprite2D

const speed = 20.0

var animation_progress : float = 0
var walking_animation_weight : float = 0

var current_pos : Vector2i
var target_pos : Vector2

var is_moving : bool = false

var x_direction = 1

func _ready() -> void:
	current_pos = Vector2i(1, 1)
	position = (Vector2(0.5, 0.8) + Vector2(current_pos)) * maze.tile_scale
	target_pos = position

func _unhandled_input(event: InputEvent) -> void:
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

func move_to_tile(x : int, y : int, instant : bool = false):
	if maze.is_walkable(x, y):
		current_pos.x = x
		current_pos.y = y

		target_pos.x = (0.5 + current_pos.x) * maze.tile_scale 
		target_pos.y = (0.8 + current_pos.y) * maze.tile_scale 
		
		maze.check_item_pickup(x, y)

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
	await get_tree().create_timer(0.5).timeout

func animate(delta : float):
	sprite.scale.x = x_direction

	walking_animation_weight = lerpf(walking_animation_weight, 0, delta / 0.2)

	animation_progress += speed * delta * 1
	
	sprite.rotation = (sin(animation_progress) * 0.1) * walking_animation_weight + (sin(animation_progress / 4) * 0.01)
	sprite.scale.y = 1 - (sin(animation_progress * 2) * .01) * walking_animation_weight + -((1 + sin(animation_progress * .5)) * .01)
	sprite.position.y = 0 + (-(1 + sin(animation_progress * 2 - PI / 2)) * 10.25) * walking_animation_weight

	sprite.reset_physics_interpolation()
