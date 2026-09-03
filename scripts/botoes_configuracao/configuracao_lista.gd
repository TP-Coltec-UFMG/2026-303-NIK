# @tool
extends ConfigButton
class_name ConfigButtonList

@export var vertical : bool = false
@export var values : Array[String] = ["preciso de values :("]
@export var value = "ay cabron"
var _value : int = 0:
	set(new_value):
		if values.size() > 0:
			_value = (new_value + values.size()) % values.size()
			value = values[_value]
		else:
			_value = 0
		queue_redraw()

var is_editing : bool = false:
	set(v):
		is_editing = v
		queue_redraw()

func _ready() -> void:
	super._ready() 
	if value in values:
		_value = values.find(value)
	else: _value = 0

func _draw() -> void:
	var color = get_theme_color("color_default", theme_variation)
	var outline = Color.TRANSPARENT
	
	if is_editing:
		color = get_theme_color("color_pressed", theme_variation)
		outline = get_theme_color("color_pressed_outline", theme_variation)
	elif has_focus():
		color = get_theme_color("color_focus", theme_variation)
		outline = get_theme_color("color_focus_outline", theme_variation)

	var offset
	offset = draw_text(label, Vector2.ZERO, color, outline)
	
	var value_color
	var outline_value
	if is_editing: 
		value_color = get_theme_color("color_focus", theme_variation)
		outline_value = get_theme_color("color_focus_outline", theme_variation)
	else: 
		value_color = get_theme_color("color_pressed", theme_variation)
		outline_value = get_theme_color("color_pressed_outline", theme_variation)

	var value_pos
	if not vertical:
		value_pos = Vector2(offset.x + 40, 0)
	else:
		value_pos = Vector2(0, offset.y)

	var offset_valor = draw_text(str(value), value_pos, value_color, outline_value)
	if is_editing:
		var font = get_theme_font("font", "Button")
		var font_size = get_theme_font_size("font_size", "Button")

		var arrow_size = font.get_string_size("<", HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		if not vertical:
			draw_text("<", Vector2((value_pos.x + 20) - arrow_size.x / 2, 0), value_color, outline_value)
			draw_text(">", Vector2((value_pos.x + offset_valor.x + 40 + 20) - arrow_size.x / 2, 0), value_color, outline_value)
		else:
			draw_text("<", Vector2(-arrow_size.x / 2 - 20, value_pos.y), value_color, outline_value)
			draw_text(">", Vector2((offset_valor.x + 40 + 20) - arrow_size.x / 2 - 40, value_pos.y), value_color, outline_value)

func _gui_input(event: InputEvent) -> void:
	if is_editing:
		var changed = false
		if event.is_action_pressed("ui_right"):
			_value += 1
			changed = true
		elif event.is_action_pressed("ui_left"):
			_value -= 1
			changed = true
			
		# nao deixa o godot passar o foco para outra configuracao
		if changed or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
			accept_event() 
		
		if changed:
			GameManager.change_setting(id, value)
			
	# alterna o modo de edicao
	if event.is_action_released("ui_accept"):
		is_editing = !is_editing

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_FOCUS_EXIT:
			is_editing = false # tira o is_editing se sair (na teoria nao precisa, mas é bom garantir)

# func _pressed() -> void:
# 	is_editing = !is_editing # Alterna a edição do value
