class_name thought_generator extends Node2D

@export var thought_scene : PackedScene
@export var good_thought_textures : Array[Texture2D]
@export var bad_thought_textures : Array[Texture2D]
@export var joao : Sprite2D
@export var label_points : Label
@onready var protector : Protector = get_tree().current_scene as Protector
const radius : float = 1480.0
var points : int = 0
var flag : int = 10
var thoughts : Array[Thought] = []
var generate : bool = true

func _ready() -> void:
	create_thought()

func create_thought() -> void:
	while(true):
		if generate:
			if points < flag:
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
				if thought.damage: thought.destroyed.connect(count_destroyed)
				thoughts.append(thought)
				thought.tree_exited.connect(func(): thoughts.erase(thought))
				
				await get_tree().create_timer(1).timeout
			else:
				generate = false

		else:
			if thoughts.is_empty():
				await get_tree().create_timer(1).timeout
				if points >= 30:
					protector.end_game()
				elif points >= 20:
					DialogueController.start_dialogue("joao_minigame_dialogue_2")
					await DialogueController.dialogue_finished
				elif points >= 10:
					DialogueController.start_dialogue("joao_minigame_dialogue_1")
					await DialogueController.dialogue_finished
				flag += 10
				generate = true
				
			else:
				await get_tree().process_frame

func count_destroyed() -> void:
	points += 1
	label_points.text = str(points) + "/30"
