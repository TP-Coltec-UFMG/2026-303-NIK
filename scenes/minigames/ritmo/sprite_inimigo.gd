extends Sprite2D

@export var voa : bool = false
@onready var posicao_y = position.y
@onready var rotacao = rotation
var anim = 0

func _process(delta: float) -> void:
	anim = fmod(anim + delta * 2, PI * 2)
	if voa:
		position.y = lerpf(position.y, posicao_y + sin(anim) * 15, delta / 0.1)
		rotation = lerpf(rotation, rotacao + sin(anim * 2) * 0.1, delta / 0.1)
