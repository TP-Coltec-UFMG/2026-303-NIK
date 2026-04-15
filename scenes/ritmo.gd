extends Node

@onready var pistas = {
	1: $Pista1,
	2: $Pista2,
	3: $Pista3,
	4: $Pista4
}

func _ready() -> void:
	notas_aleatorias()

func _process(delta: float) -> void:
	pass

func notas_aleatorias() -> void:
	await get_tree().create_timer(0.25).timeout
	var pista = randi_range(1, 4)

	pistas[pista].criar_nota((pista - 2) * 12 + randi_range(0, 12))
	notas_aleatorias()
