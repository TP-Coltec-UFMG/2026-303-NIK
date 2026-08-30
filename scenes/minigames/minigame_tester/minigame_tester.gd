extends CanvasLayer

@onready var complete_button : Button = $Complete

func _ready() -> void:
	complete_button.connect("pressed", GameManager.load_map)
	GameManager.set_game_data("minigame_dona_luzia_complete", true);
