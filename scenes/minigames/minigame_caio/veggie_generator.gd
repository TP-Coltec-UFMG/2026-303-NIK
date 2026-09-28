extends Node2D

var next_veggie_time : float

@onready var veggies : Array[Area2D] = [ $Potato, $Carrot ]

func _ready() -> void:
	next_veggie_time = 1.0



func _process(delta: float) -> void:
	next_veggie_time -= delta
	if(next_veggie_time <= 0):
		next_veggie_time = -0.5 * log(1 - maxf(randf(), 0.3)) * 5
		var veggie = veggies.pick_random()
		var clone = veggie.duplicate()
		clone.process_mode = Node.PROCESS_MODE_ALWAYS
		clone.template = false
		clone.visible = true
		add_child(clone)
