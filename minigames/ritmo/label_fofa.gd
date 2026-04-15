extends Label3D

func _process(delta: float) -> void:
	position.y += delta
	modulate.a -= delta
	outline_modulate.a -= delta

	if modulate.a <= 0:
		queue_free()
