@tool
extends Control
class_name Barra

enum Direcao { DIREITA, ESQUERDA, CIMA, BAIXO }

var _preenchimento : float = 0:
	set(valor):
		_preenchimento = valor
		queue_redraw()
@export_range(0, 1) var preenchimento : float = 0.5:
	set(valor):
		preenchimento = valor
		animacao_slider()

@export var direcao : Direcao = Direcao.DIREITA:
	set(valor):
		direcao = valor
		queue_redraw()


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
	var offset = Vector2(4, 4)
	var tamanho_reducao = Vector2(8, 8)
	draw_rect(Rect2(offset, size - tamanho_reducao), cor_fundo)

	match direcao:
		Direcao.DIREITA:
			draw_rect(Rect2(offset + Vector2.ZERO, Vector2(size.x * _preenchimento, size.y) - tamanho_reducao), cor_preenchimento)
		Direcao.ESQUERDA:
			draw_rect(Rect2(offset + Vector2(size.x * (1 - _preenchimento), 0), Vector2(size.x * _preenchimento , size.y) - tamanho_reducao), cor_preenchimento)
		Direcao.CIMA:
			draw_rect(Rect2(offset + Vector2(0, size.y * (1 - _preenchimento)), Vector2(size.x, size.y * _preenchimento) - tamanho_reducao), cor_preenchimento)
		Direcao.BAIXO:
			draw_rect(Rect2(offset + Vector2.ZERO, Vector2(size.x, size.y * _preenchimento) - tamanho_reducao), cor_preenchimento)

	draw_style_box(style_box, Rect2(Vector2.ZERO, size))

	
func animacao_slider() -> void:
	if tween:
		tween.kill()
		
	tween = create_tween()
	
	tween.set_trans(Tween.TRANS_EXPO)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "_preenchimento", preenchimento, 0.5)
	
