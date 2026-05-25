class_name NPC extends Interagivel

@export var dialogo : String
func interagir() -> void:
	Dialogo.iniciar_dialogo(dialogo)