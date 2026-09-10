class_name thought_generator extends Node2D

@export var thought_scene : PackedScene
@export var thought_textures: Array[Texture2D]
@export var joao : Sprite2D
const radius : float = 1480.0

func _ready() -> void:
	create_thought()

func create_thought() -> void:
	for i in range(45):
		var angle = atan2(randfn(0.0, 0.2), randfn(0.0, 1.0))

		var thought = thought_scene.instantiate()
		if thought_textures.size() > 0:
			thought.textura = thought_textures.pick_random()
		add_child(thought)
		thought.position = Vector2(cos(angle) * radius, sin(angle) * radius)
		thought.move()
		thought.reset_physics_interpolation()
		
		await get_tree().create_timer(1.25).timeout
