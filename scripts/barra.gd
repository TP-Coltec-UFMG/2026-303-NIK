@tool
extends Control
class_name Barra

var _preenchimento : float = 0:
	set(valor):
		_preenchimento = valor
		queue_redraw()
@export_range(0, 1) var preenchimento : float = 0.5:
	set(valor):
		preenchimento = valor
		animacao_slider()

@export var cor_fundo : Color = Color.DARK_GRAY:
	set(valor):
		cor_fundo = valor
		queue_redraw()
@export var cor_contorno : Color = Color.DARK_SLATE_BLUE:
	set(valor):
		cor_contorno = valor
		if style_box: style_box.border_color = cor_contorno
		queue_redraw()
@export var cor_preenchimento : Color = Color.SLATE_BLUE:
	set(valor):
		cor_preenchimento = valor
		queue_redraw()

var style_box : StyleBoxFlat
var tween : Tween

func _ready() -> void:
	style_box = StyleBoxFlat.new()

	style_box.bg_color = Color.TRANSPARENT
	style_box.draw_center = false

	style_box.border_color = cor_contorno
	style_box.set_border_width_all(8)
	style_box.set_corner_radius_all(4)

	style_box.anti_aliasing = true

func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, size), cor_fundo)
	draw_rect(Rect2(Vector2.ZERO, Vector2(size.x * _preenchimento, size.y)), cor_preenchimento)
	draw_style_box(style_box, Rect2(Vector2.ZERO - Vector2(2, 2), size + Vector2(4, 4)))

	
func animacao_slider() -> void:
	if tween:
		tween.kill()
		
	tween = create_tween()
	
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "_preenchimento", preenchimento, 0.1)
	
