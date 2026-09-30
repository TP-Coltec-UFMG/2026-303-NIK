extends Node2D
class_name VeggieGenerator

var next_veggie_time : float
var interval_multiplier : float = 2.5

@onready var veggies : Array[Area2D] = [ $Potato, $Carrot, $Beet ]
@onready var label : Label = $CanvasLayer/Label

var points : int = 0
var active_game : bool = false
var game_ended : bool = false

func _ready() -> void:
	next_veggie_time = 1.0
	GameManager.play_music('kitchen')

func _process(delta: float) -> void:
	if not DialogueController.active_dialogue and active_game:
		next_veggie_time -= delta
		if(next_veggie_time <= 0):
			next_veggie_time = -0.5 * log(1 - maxf(randf(), 0.5)) * interval_multiplier
			var veggie = veggies.pick_random()
			var clone = veggie.duplicate()
			clone.process_mode = Node.PROCESS_MODE_ALWAYS
			clone.template = false
			clone.visible = true
			clone.sliced.connect(veggie_sliced)
			add_child(clone)

func veggie_sliced():
	points += 1
	label.text = str(points) + "/30"

	if points == 10:
		interval_multiplier *= 0.75
		DialogueController.start_dialogue("caio_minigame_dialogue_1")
		await DialogueController.dialogue_finished
	if points == 20:
		interval_multiplier *= 0.75
		DialogueController.start_dialogue("caio_minigame_dialogue_2")
		await DialogueController.dialogue_finished
	if points == 30:
		DialogueController.start_dialogue("caio_minigame_dialogue_3")
		await DialogueController.dialogue_finished
		game_ended = true

		var tween = create_tween()
		tween.set_trans(Tween.TRANS_EXPO)
		tween.tween_property(self, "interval_multiplier", 0.001, 3)
		interval_multiplier *= 0.05

		await tween.finished
		end_game()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("skip_minigame"):
		end_game()

func _on_play_pressed():
	$Tutorial.visible = false

	# Dá um tempo entre o play e o jogo realmente começar
	await get_tree().create_timer(1).timeout
	active_game = true

func end_game():
	GameManager.load_map()
	GameManager.set_game_data("caio_minigame_completed", true)
	GameManager.load_map_with_dialogue("caio_post_minigame")
