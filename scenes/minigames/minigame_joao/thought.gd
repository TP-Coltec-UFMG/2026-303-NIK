class_name Thought extends Area2D

@export var textura : Texture2D
@export var damage : bool = randf_range(0, 1) < 0.5
@onready var sprite = $Sprite2D
var tween : Tween
signal blocked
signal arrived

func _ready() -> void:
	if textura:
		sprite.texture = textura;

func block() -> void:
	emit_signal("blocked");
	
	tween.kill()
		
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "scale", Vector2.ZERO, .1)
	await tween.finished

	queue_free()

func move() -> void:
	var target_pos = Vector2(0, 0)
	
	if tween:
		tween.kill()
		
	tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	
	tween.tween_property(self, "position", target_pos, 3)
	tween.finished.connect(_on_tween_finished)

func _on_tween_finished() -> void:
	tween.kill()
		
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "scale", Vector2.ZERO, .1)
	await tween.finished

	arrived.emit()

	queue_free()
