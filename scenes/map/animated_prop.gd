extends Node2D
class_name AnimatedProp

var animation_progress : float = 0

@export var type: PropTypes.Type = PropTypes.Type.PERSON:
	set(value):
		type = value
		if type == PropTypes.Type.SLEEPING:
			sleep()
@export var conditions: Array[Resource]

@export_category("RUNNING")
@export var radius : Vector2 = Vector2.ZERO
@export var duration : float = 5.0
@export_range(0.0, PI * 2) var running_progress : float = 0.0
var tail
var animate = true


@onready var start_position = position

func _ready() -> void:
	if type == PropTypes.Type.BIRD:
		chirp()
	if type == PropTypes.Type.SLEEPING:
		sleep()
	
	for condition in conditions:
		if GameManager.get_game_data(condition.condition) == condition.value:
			if condition is AnimationCondition: type = condition.true_type
			else: $Sprite2D.texture = condition.true_sprite
		else: 
			if condition is AnimationCondition: type = condition.false_type
			else: $Sprite2D.texture = condition.false_sprite

func _process(delta: float) -> void:
	if not animate: return
		
	animation_progress += 300 * delta * .035 * (3.0 if type == PropTypes.Type.RUNNING else 0.5 if type == PropTypes.Type.SLEEPING else 1.0)

	scale.y = 1.0 - ((1 + sin(animation_progress * .5)) * .01)

	reset_physics_interpolation()

	if type == PropTypes.Type.RUNNING:
		rotation = (sin(animation_progress / 3.0) * 0.1)
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
	
	var particle = GameManager.chirp_particle.instantiate() as GPUParticles2D

	add_child(particle)
	particle.global_position = global_position
	#print("chirp")

	chirp()

func sleep():
	var particle = get_node_or_null("Sleep")
	if not particle:
		particle = GameManager.sleep_particle.instantiate() as GPUParticles2D
		add_child(particle)
		particle.global_position = global_position