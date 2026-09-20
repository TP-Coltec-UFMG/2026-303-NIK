class_name NikoleProtector extends Node2D

@onready var sprite : Sprite2D = $Sprite2D
@onready var previous_x = sprite.global_position.x;
@export var label_points : Label
@export var joao : Sprite2D
const speed = 20.0
const radius : float = 338.7/2
var animation_progress : float = 0
var walking_animation_weight : float = 0
var points : int = 0

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
	points = int(label_points.text.replace("/30", ""))

func _on_area_entered(area: Area2D) -> void:
	if area is Thought:
		if area.damage: 
			points += 1
			label_points.text = str(points) + "/30"
		area.block()
