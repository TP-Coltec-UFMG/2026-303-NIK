class_name Nikole extends CharacterBody3D


@export var speed = 30.0

const JUMP_VELOCITY = -400.0

@onready var sprites : Node3D = $Sprites
@onready var right_hand : Node3D = $Sprites/RightHand
@onready var right_hand_base_position : Vector3 = $Sprites/RightHand.position
@onready var left_hand : Node3D = $Sprites/LeftHand
@onready var left_hand_base_position : Vector3 = $Sprites/LeftHand.position
@onready var hair : Node3D = $Sprites/Head/Hair
@onready var hair_base_position : Vector3 = $Sprites/Head/Hair.position
@onready var sprites_scale : float = $Sprites.scale.x
var sprite_direction = 1
var flip : float

var animation_progress : float = 0
var walking_animation_weight : float = 0
var walking : bool

var move_input : Vector2

func _physics_process(delta: float) -> void:
	var raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move_input = move_input.lerp(raw_input, delta / 0.2)

	walking = raw_input.length() > 0

	if raw_input.x != 0:
		sprite_direction = 1 if raw_input.x > 0 else -1

	velocity.x = move_input.x * speed
	velocity.z = move_input.y * speed

	move_and_slide()

func _process(delta: float) -> void:
	# animations
	walking_animation_weight = lerpf(walking_animation_weight, 1 if walking else 0, delta / .075)

	# sprites.scale.x = lerpf(sprites.scale.x, sprites_scale * -sprite_direction, delta / 0.05)
	# flip = lerpf(flip, PI / 2 * -sprite_direction, delta / 0.1)
	# flip = PI / 2 * -sprite_direction
	sprites.scale.x = sprite_direction;

	animation_progress += speed * delta * .275
	
	sprites.rotation.z = (sin(animation_progress) * 0.05) * walking_animation_weight + (sin(animation_progress / 4) * 0.01)
	sprites.scale.y = 1 - (sin(animation_progress * 2) * .01) * walking_animation_weight + -((1 + sin(animation_progress * .5)) * .01)
	sprites.position.y = 1 + ((1 + sin(animation_progress * 2 - PI / 2)) * .25) * walking_animation_weight
	left_hand.position.x = left_hand_base_position.x - (sin(animation_progress - PI / 2) * .6) * walking_animation_weight
	left_hand.position.y = left_hand_base_position.y + (sin(2 * animation_progress + PI / 2) * .125) * walking_animation_weight
	right_hand.position.x = right_hand_base_position.x + (sin(animation_progress - PI / 2) * .6) * walking_animation_weight
	right_hand.position.y = right_hand_base_position.y + (sin(2 * animation_progress + PI / 2) * .125) * walking_animation_weight
	hair.rotation.z = (sin(animation_progress) * 0.05) * walking_animation_weight

	sprites.reset_physics_interpolation()

func _on_door_body_entered(body: Node3D, source: Area3D) -> void:
	if source is Door and body is Nikole:
		print_debug("entrar na casa de " + source.house_owner + "?")
