extends GPUParticles2D 
class_name NPCParticles

@export var condition : String
@export var value : bool

func _ready() -> void:
	if GameManager.get_game_data(condition) != value: emitting = false

func update() -> void:
	if GameManager.get_game_data(condition) != value: emitting = false