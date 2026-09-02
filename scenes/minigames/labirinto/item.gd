extends Sprite2D

@export var nikole : Node2D

var collected = false
var placed = false
@export var follow_offset : Vector2
var target_pos : Vector2
@export var animated : bool
var animation_progress = 0.0
@onready var base_offset = offset

func _process(delta: float) -> void:
	if collected and not placed:
		target_pos = nikole.position + Vector2(follow_offset.x * nikole.x_direction, follow_offset.y)
	if collected or placed:
		position = lerp(position, target_pos, delta / 0.1)

	if animated: animate(delta)


func animate(delta : float):
	scale.x = nikole.x_direction

	var walking_animation_weight = min(1, position.distance_to(target_pos) / 300)
	if not collected or placed: walking_animation_weight = 0

	animation_progress += nikole.speed * delta * 1
	
	rotation = (sin(animation_progress) * 0.1) * walking_animation_weight + (sin(animation_progress / 4) * 0.01)
	scale.y = 1 - (sin(animation_progress * 2) * .01) * walking_animation_weight + -((1 + sin(animation_progress * .5)) * .01)
	offset.y = base_offset.y + (-(1 + sin(animation_progress * 2 - PI / 2)) * 10.25) * walking_animation_weight

	reset_physics_interpolation()
