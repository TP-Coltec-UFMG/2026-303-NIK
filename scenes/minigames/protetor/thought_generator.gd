class_name thought_generator extends Node

@export var thought_scene : PackedScene
@export var thought_textures: Array[Texture2D]
@export var joao : Sprite2D
const radius : float = 3700.0

func _ready() -> void:
	create_thought()

func create_thought() -> void:
	for i in range(45):
		var angle : float = randf_range(0, 360)
		var thought = thought_scene.instantiate()
		if thought_textures.size() > 0:
			thought.textura = thought_textures.pick_random()
		add_child(thought)
		thought.position = Vector2(cos(angle)*radius+joao.position.x, sin(angle)*radius+joao.position.y)
		thought.slider_animation()
		await get_tree().create_timer(2).timeout
