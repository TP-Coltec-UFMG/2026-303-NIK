class_name NikoleProtector extends Node2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var previous_x = sprite.global_position.x;
@export var joao : Sprite2D
const speed = 20.0
const radius : float = 338.7/2
var animation_progress : float = 0
var walking_animation_weight : float = 0

var current_angle = 0
var target_angle

func _ready() -> void:
	position = Vector2(joao.position.x, joao.position.y - radius)

func _process(delta: float) -> void:
	var direction = get_global_mouse_position() - joao.position
	target_angle = atan2(direction.y, direction.x)

	current_angle = lerp_angle(current_angle, target_angle, delta / 0.1)

	sprite.rotation = current_angle + PI / 2
	position = Vector2(cos(current_angle) * radius + joao.position.x, sin(current_angle) * radius + joao.position.y)
	# if position.x <= joao.position.x: x_direction = -1
	# else: x_direction = 1
	# scale.x = x_direction
	
func _on_area_entered(area: Area2D) -> void:
	if area is Thought:
		area.destroy()
