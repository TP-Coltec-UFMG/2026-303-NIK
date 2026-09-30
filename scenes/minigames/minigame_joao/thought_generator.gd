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
var odds : float = 0.75
var interval_multiplier : float = 1

func _ready() -> void:
	points = int(label_points.text.replace("/30", ""))

func _process(delta: float) -> void:
	pass

func create_thought() -> void:
	while(true):
		if generate:
			if points < flag:
				var angle = atan2(randfn(0.0, 0.2), randfn(0.0, 1.0))

				var thought = thought_scene.instantiate() as Thought
				thought.damage = randf() <= odds
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
				thoughts.append(thought)
				thought.blocked.connect(blockedPoints.bind(thought))
				thought.arrived.connect(arrivedPoints.bind(thought))
				thought.tree_exited.connect(func(): thoughts.erase(thought))
				
				await get_tree().create_timer(1 * interval_multiplier).timeout
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
					protector.animation_amplitude *= 0.75
					protector.animation_speed *= 0.75
					odds = 0.25
					interval_multiplier *= 0.8
				elif points >= 10:
					DialogueController.start_dialogue("joao_minigame_dialogue_1")
					await DialogueController.dialogue_finished
					protector.animation_amplitude *= 0.75
					protector.animation_speed *= 0.75
					odds = 0.5
					interval_multiplier *= 0.8
				flag += 10
				generate = true
				
			else:
				await get_tree().process_frame

func arrivedPoints(thought : Thought) -> void:
	if !thought.damage: points += 1
	updateLabel()

func blockedPoints(thought : Thought) -> void:
	if thought.damage: points += 1
	updateLabel()

func updateLabel():
	label_points.text = str(min(30, points)) + "/30"

func _on_play_pressed() -> void:
	print("iniciar jogo joão")
	$"../../Tutorial".visible = false
	# Dá um tempo entre o play e o jogo realmente começar
	await get_tree().create_timer(1).timeout
	create_thought()
