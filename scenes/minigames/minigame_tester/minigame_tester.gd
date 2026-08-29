extends CanvasLayer

@onready var complete_button : Button = $Complete

func _ready() -> void:
	complete_button.connect("pressed", MestreSupremo.carregar_mapa)
