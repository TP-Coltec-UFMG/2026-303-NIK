extends Node2D

var animation_progress : float = 0

enum PROP_TYPE { PERSON, BIRD, RUNNING }
@export var type: PROP_TYPE = PROP_TYPE.PERSON

@export_category("RUNNING")
@export var radius : Vector2 = Vector2.ZERO
@export var duration : float = 5.0
@export_range(0.0, PI * 2) var running_progress : float = 0.0

@onready var start_position = position

func _ready() -> void:
	if type == PROP_TYPE.BIRD:
		chirp()
	pass

func _process(delta: float) -> void:
	animation_progress += 150 * delta * .035
	
	rotation = (sin(animation_progress / 4) * 0.025) + (sin(animation_progress) * 0.1) if type == PROP_TYPE.RUNNING else 0.0
	scale.y = 1 - (sin(animation_progress * 2) * .025)

	if type == PROP_TYPE.RUNNING:
		running_progress = fmod(running_progress + PI * 2 * delta / duration, PI * 2)
		position.x = start_position.x + cos(running_progress) * radius.x
		position.y = start_position.y + sin(running_progress) * radius.y
		scale.x = 1.0 if position.y > start_position.y else -1.0

	reset_physics_interpolation()

func chirp():
	var particle = (load("res://scenes/map/chirp.tscn") as PackedScene).instantiate() as GPUParticles2D
	add_child(particle)
	particle.global_position = global_position
	print("chirp")

	await get_tree().create_timer(randf_range(0.5, 3.0)).timeout

	chirp()
