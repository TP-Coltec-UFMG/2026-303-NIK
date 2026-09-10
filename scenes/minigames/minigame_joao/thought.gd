class_name Thought extends Area2D

@export var textura : Texture2D
@onready var sprite = $Sprite2D
var tween : Tween
signal destroyed

func _ready() -> void:
	if textura:
		sprite.texture = textura;

func destroy() -> void:
	emit_signal("destroyed");
	queue_free()

func move() -> void:
	var target_pos = Vector2(0, 0)
	
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	tween.tween_property(self, "position", target_pos, 5)
