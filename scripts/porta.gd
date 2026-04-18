class_name Porta extends Interagivel

@export var dono = "Nikole"
@export var cena : PackedScene

func interagir() -> void:
	Transicao.carregar_cena(cena)
