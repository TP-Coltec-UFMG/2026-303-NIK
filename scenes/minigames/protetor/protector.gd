class_name Protector extends Node

var jogo_finalizado : bool = false

@onready var joao = $Joao
var animation_progress : float = 0.0

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	animate(delta)
	

func animate(delta : float):
	animation_progress += 15 * delta
	
	joao.rotation = ((sin(animation_progress)**2 * 0.025) + (sin(animation_progress * 1) * 0.075)) * .25
	joao.scale.y = 0.5 - (sin(animation_progress * 4)**10 * 0.01) - (sin(animation_progress * 2) * 0.02)

	joao.reset_physics_interpolation()


func start_game() -> void:
	pass
