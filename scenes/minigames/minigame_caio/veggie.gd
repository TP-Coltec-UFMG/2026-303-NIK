extends Area2D

var speed : Vector2
var rotation_speed : float

@onready var sprite : Sprite2D = $Sprite
@onready var slice_a : GPUParticles2D = $A
@onready var slice_b : GPUParticles2D = $B
@export var template = false

func _ready() -> void:
	if template:
		visible = false
		return
	var start_angle = randf_range(0, PI)
	position = Vector2(cos(start_angle), sin(start_angle)) * 1500

	reset_physics_interpolation()

	var direction_to_center = (Vector2(640 - randf_range(-200, 200), 360 + randf_range(-620 , -1860)) - global_position)
	var distance_to_center = direction_to_center.length()
	direction_to_center = direction_to_center.normalized()
	rotation_speed = randf_range(2.5, 7.5) * (1 if randi() % 2 > 0 else -1)
	speed = direction_to_center * distance_to_center * 0.75

	mouse_exited.connect(slice)

func _process(delta: float) -> void:
	if sprite.visible:
		rotation += rotation_speed * delta
	position += speed * delta
	speed.y += delta * 1250

func slice():
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT) and sprite.visible:
		slice_a.emitting = true
		slice_b.emitting = true
		sprite.visible = false

		await get_tree().create_timer(15).timeout
		queue_free()