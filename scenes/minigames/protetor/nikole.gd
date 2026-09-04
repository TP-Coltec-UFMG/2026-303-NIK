class_name nikole extends Node2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var previous_x = sprite.global_position.x;
@export var joao : Sprite2D
const speed = 20.0
const radius : int = 520
var animation_progress : float = 0
var walking_animation_weight : float = 0
var current_pos : Vector2i
var target_pos : Vector2
var x_direction = 1

func _ready() -> void:
	position = Vector2(joao.position.x, joao.position.y - radius)

func _process(delta: float) -> void:
	var direction = get_global_mouse_position() - joao.position
	var angle = atan2(direction.y, direction.x)
	position = Vector2(cos(angle)*radius+joao.position.x, sin(angle)*radius+joao.position.y)
	if position.x <= joao.position.x: x_direction = -1
	else: x_direction = 1
	scale.x = x_direction
	
func _on_area_entered(area: Area2D) -> void:
	if area is Thought:
		area.destroy()
