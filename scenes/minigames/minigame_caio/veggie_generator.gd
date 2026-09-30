extends Node2D
class_name VeggieGenerator

var next_veggie_time : float
var interval_multiplier : float = 3

@onready var veggies : Array[Area2D] = [ $Potato, $Carrot, $Beet ]
@onready var label : Label = $CanvasLayer/Label

var points : int = 0

func _ready() -> void:
	next_veggie_time = 1.0

func _process(delta: float) -> void:
	if not DialogueController.active_dialogue:
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
		interval_multiplier *= 0.5
		DialogueController.start_dialogue("caio_minigame_dialogue_1")
		await DialogueController.dialogue_finished
	if points == 15:
		interval_multiplier *= 0.5
		DialogueController.start_dialogue("caio_minigame_dialogue_2")
		await DialogueController.dialogue_finished
	if points == 30:
		DialogueController.start_dialogue("caio_minigame_dialogue_3")
		await DialogueController.dialogue_finished

		var tween = create_tween()
		tween.set_trans(Tween.TRANS_EXPO)
		tween.tween_property(self, "interval_multiplier", 0.001, 3)
		interval_multiplier *= 0.05

		await tween.finished
		GameManager.load_map()
		GameManager.set_game_data("caio_minigame_completed", true)
		GameManager.load_map_with_dialogue("caio_post_minigame")

		await get_tree().create_timer(3).timeout
