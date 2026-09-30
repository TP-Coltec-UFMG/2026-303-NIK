extends Node2D
class_name AnimatedProp

var animation_progress : float = 0

@export var type: PropTypes.Type = PropTypes.Type.PERSON
@export var conditions: Array[Resource]

@export_category("RUNNING")
@export var radius : Vector2 = Vector2.ZERO
@export var duration : float = 5.0
@export_range(0.0, PI * 2) var running_progress : float = 0.0

var animate = true


@onready var start_position = position

func _ready() -> void:
	if type == PropTypes.Type.BIRD:
		chirp()
	
	for condition in conditions:
		if GameManager.get_game_data(condition.condition) == condition.value:
			type = condition.true_type
			break
		type = condition.false_type

func _process(delta: float) -> void:
	if not animate: return
	
	animation_progress += 100 * delta * .035 * (3.0 if type == PropTypes.Type.RUNNING else 1.0)
	
	rotation = (sin(animation_progress / 4) * 0.0) + ((sin(animation_progress) * 0.1) if type == PropTypes.Type.RUNNING else 0.0)
	# rotation = (sin(animation_progress / 4) * 0.1) + ((sin(animation_progress) * 0.1) if type == PropTypes.Type.RUNNING else 0.0)
	scale.y = 1 - (sin(animation_progress * 2) * .025)

	if type == PropTypes.Type.RUNNING:
		running_progress = fmod(running_progress + PI * 2 * delta / duration, PI * 2)
		position.x = start_position.x + cos(running_progress) * radius.x
		position.y = start_position.y + sin(running_progress) * radius.y
		scale.x = 1.0 if position.y > start_position.y else -1.0

	reset_physics_interpolation()

var tween : Tween
func move_to(target_position : Vector2):
	tween = create_tween()
	tween\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(self, "position", target_position, 0.15)
	
	await tween.finished

	var data = GameManager.get_game_data("props")
	data[name]["position"] = {
		"x": target_position.x,
		"y": target_position.y
	}
	GameManager.set_game_data("props", data)

func chirp():
	await get_tree().create_timer(randf_range(0.5, 3.0)).timeout
	
	var particle = (load("res://scenes/map/chirp.tscn") as PackedScene).instantiate() as GPUParticles2D

	add_child(particle)
	particle.global_position = global_position
	#print("chirp")

	chirp()
