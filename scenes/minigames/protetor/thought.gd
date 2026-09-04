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

func slider_animation() -> void:
	var target_pos = Vector2(3048.0, 1715.0)
	
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "global_position", target_pos, 20)
