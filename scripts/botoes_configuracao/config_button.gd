# @tool
extends BaseButton
class_name ConfigButton

@export var id : String = "id_único!!!"
@export var label : String = "oii, eu sou uma configuracao!!"

@export var theme_variation : String = "ConfigButton"

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL



func _draw() -> void:
	draw_text(label)

func draw_text(text : String, offset : Vector2 = Vector2.ZERO, color = null, outline = null) -> Vector2:
	var is_focused = has_focus() or (get_viewport().gui_get_focus_owner() in get_children()) # ve se ta focado ele ou um bebê dele

	var text_color = get_theme_color("color_default", theme_variation)
	if not color: # aplica a color correta pro texto
		if is_pressed():
			text_color = get_theme_color("color_pressed", theme_variation)
		elif is_focused:
			text_color = get_theme_color("color_focus", theme_variation)
		if label.is_empty():
			return Vector2.ZERO
	else:
		text_color = color

	var outline_color
	if is_focused: # aplica a color correta pro outline
		if outline:
			outline_color = outline
		else:
			if not pressed:
				outline_color = get_theme_color("color_focus_outline", theme_variation)
			else:
				outline_color = get_theme_color("color_pressed_outline", theme_variation)

	# configura a fonte pra funcionar com o tema
	var font = get_theme_font("font", "Button")
	var font_size = get_theme_font_size("font_size", "Button")

	var string_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size)
	var text_pos = offset + Vector2(0, font.get_ascent(font_size) + (size.y - string_size.y) / 2)

	if is_focused:
		outline_color = get_theme_color("color_focus_outline", theme_variation)
		if is_pressed(): outline_color = get_theme_color("color_pressed_outline", theme_variation)
		if outline:
			outline_color = outline
	
	if outline_color: draw_string_outline(font, text_pos, text, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size, 10, outline_color)
	draw_string(font, text_pos, text, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size, text_color)

	return string_size # retorna a posicao em que o texto acabou

func text_size(texto : String):
	var font = get_theme_font("font", "Button")
	var font_size = get_theme_font_size("font_size", "Button")

	var string_size = font.get_string_size(texto, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size)
	return string_size
