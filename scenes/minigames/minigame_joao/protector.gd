class_name Protector extends Node

var jogo_finalizado : bool = false

@onready var joao = $Joao
var animation_progress : float = 0.0

var animation_speed : float = 1.0
var animation_amplitude : float = 1.5

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	animate(delta)
	
func animate(delta : float):
	animation_progress += 15 * delta * animation_speed
	
	joao.rotation = ((sin(animation_progress)**2 * 0.025) * animation_amplitude + (sin(animation_progress * 1) * 0.075)) * animation_amplitude * .25
	joao.scale.y = 0.5 - (sin(animation_progress * 4)**10 * 0.01 * animation_amplitude) - (sin(animation_progress * 2) * 0.02 * animation_amplitude)

	joao.reset_physics_interpolation()

func end_game() -> void:
	GameManager.load_map()
	GameManager.set_game_data("joao_minigame_completed", true)
	DialogueController.start_dialogue("joao_post_minigame")
