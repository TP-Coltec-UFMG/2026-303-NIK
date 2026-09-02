# @tool
extends ConfigButton
class_name ConfigButtonBool

@export var vertical : bool = false
@export var value : bool = false:
	set(new_value):
		value = new_value
		GameManager.change_setting(id, value)

@export var textEnabled = "ligado";
@export var textDisabled = "disabled";

func _ready() -> void:
	super._ready() 

func _draw() -> void:
	var color = get_theme_color("color_default", theme_variation)
	var outline = Color.TRANSPARENT
	
	if has_focus():
		color = get_theme_color("color_focus", theme_variation)
		outline = get_theme_color("color_focus_outline", theme_variation)

	var offset = draw_text(label, Vector2.ZERO, color, outline)

	var value_pos
	var value_color
	var value_outline
	if vertical:
		value_pos = Vector2(0, offset.y - 5)
	else:
		value_pos = Vector2(offset.x + 10, 0)

	if value:
		value_color = get_theme_color("color_pressed", theme_variation)
		value_outline = get_theme_color("color_pressed_outline", theme_variation)
	else:
		value_color = get_theme_color("color_focus", theme_variation)
		value_outline = get_theme_color("color_focus_outline", theme_variation)

	# if valorOverride:
	# 	desenha_texto("ligado" if value else "disabled", value_pos, value_color, outline_value)
	# else:
	# 	desenha_texto("ligado" if value else "disabled", value_pos, value_color, outline_value)
	draw_text(textEnabled if value else textDisabled, value_pos, value_color, value_outline)

func _pressed() -> void:
	value = !value