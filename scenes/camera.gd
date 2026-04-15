extends Camera3D

@onready var offset : Vector3 = position
@export var alvo : Node3D
@export var velocidade : float = 10.0

func _process(delta: float) -> void:
	var posicao_alvo = offset + alvo.position
	position.x = lerpf(position.x, posicao_alvo.x, delta * velocidade)
	position.y = lerpf(position.y, posicao_alvo.y, delta * velocidade)
	position.z = lerpf(position.z, posicao_alvo.z, delta * velocidade)
