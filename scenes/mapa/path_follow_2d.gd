extends PathFollow2D

# Define your stops as values between 0.0 (start) and 1.0 (end)
@export var stops: Array[float] = [0.0, 0.5, 1.0]
# How many seconds it takes to travel between stops
@export var travel_time: float = 0.6 

@export var velocidade = 30.0

var flip : float = 1

var progresso_animacao : float = 0
var peso_animacao_andar : float = 0

var current_stop_index: int = 0
var is_moving: bool = false

@onready var sprite : Sprite2D = $Nikole;

func _ready() -> void:
	# Ensure the node snaps to the first stop immediately on load
	if not stops.is_empty():
		progress_ratio = stops[current_stop_index]

func _unhandled_input(event: InputEvent) -> void:
	# Ignore input if the node is currently in transit
	if is_moving:
		return

	if event.is_action_pressed("ui_right"):
		move_to_stop(current_stop_index + 1)
	elif event.is_action_pressed("ui_left"):
		move_to_stop(current_stop_index - 1)

func move_to_stop(target_index: int) -> void:
	# Prevent going out of bounds
	if target_index < 0 or target_index >= stops.size():
		return
		
	is_moving = true
	current_stop_index = target_index
	var target_ratio: float = stops[current_stop_index]
	
	# Create a tween for smooth movement
	var tween = create_tween()
	
	# SINE transition and IN_OUT easing creates a smooth accelerate/decelerate effect
	tween.set_trans(Tween.TRANS_LINEAR)
	# tween.set_ease(Tween.EASE_IN_OUT)
	
	# Tween the progress_ratio property to move the node
	tween.tween_property(self, "progress_ratio", target_ratio, travel_time)
	
	# Unlock input once the tween completes
	tween.tween_callback(func(): is_moving = false)
	
func _process(delta: float) -> void:		
	animar(delta)

func animar(delta : float):
	peso_animacao_andar = lerpf(peso_animacao_andar, 1 if is_moving else 0, delta / .075)

	sprite.scale.x = 1 * flip;

	progresso_animacao += velocidade * delta * .035
	
	sprite.rotation = (sin(progresso_animacao) * 0.15) * peso_animacao_andar + (sin(progresso_animacao / 4) * 0.01)
	sprite.scale.y = 1 - (sin(progresso_animacao * 2) * .01) * peso_animacao_andar + -((1 + sin(progresso_animacao * .5)) * .01)
	sprite.position.y = 0 + (-(1 + sin(progresso_animacao * 2 - PI / 2)) * 10.25) * peso_animacao_andar

	sprite.reset_physics_interpolation()
