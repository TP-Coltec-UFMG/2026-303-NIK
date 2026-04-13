extends Camera3D

@onready var offset : Vector3 = position
@export var target : Node3D
@export var speed : float = 1.5

func _process(delta: float) -> void:
	var target_position = offset + target.position
	position.x = lerpf(position.x, target_position.x, delta * speed)
	position.y = lerpf(position.y, target_position.y, delta * speed)
	position.z = lerpf(position.z, target_position.z, delta * speed)
