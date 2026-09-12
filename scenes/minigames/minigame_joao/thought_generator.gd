class_name thought_generator extends Node2D

@onready var protector : Protector = get_tree().current_scene as Protector
@export var thought_scene : PackedScene
@export var good_thought_textures : Array[Texture2D]
@export var bad_thought_textures : Array[Texture2D]
@export var joao : Sprite2D
var destroyed_quant : int = 0
const radius : float = 1480.0
const thought_quant : int = 20

func _ready() -> void:
	create_thought()

func create_thought() -> void:
	for i in range(thought_quant):
		var angle = atan2(randfn(0.0, 0.2), randfn(0.0, 1.0))

		var thought = thought_scene.instantiate() as Thought
		if !thought.damage:
			if good_thought_textures.size() > 0:
				thought.textura = good_thought_textures.pick_random()
		else:
			if bad_thought_textures.size() > 0:
				thought.textura = bad_thought_textures.pick_random()
		add_child(thought)
		thought.position = Vector2(cos(angle) * radius, sin(angle) * radius)
		thought.move()
		thought.reset_physics_interpolation()
		thought.destroyed.connect(count_destroyed)
		
		await get_tree().create_timer(1.25).timeout

func count_destroyed() -> void:
	destroyed_quant += 1
	if destroyed_quant == thought_quant: protector.end_game()
