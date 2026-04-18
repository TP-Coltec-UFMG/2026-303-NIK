extends MeshInstance3D

@export var duration = 2.0
@export var sin_duration = 4.0
@onready var parent_base_z = get_parent().position.z
var t = 0.0
var w = 0.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t = fmod(t + delta / duration, 1.0)
	w = fmod(t + delta / sin_duration, 1.0)
	material_override.uv1_offset.x = lerp(0.0, 1.0, t)
	get_parent().position.z = parent_base_z + (sin(w * TAU) * 10)
