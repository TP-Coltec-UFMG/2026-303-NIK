# @tool
extends ConfigButton
class_name ConfigButtonKeybind

@export var vertical : bool = false
@export var input : String = "move_right"
@export var value : Key:
	set(new_value):
		value = new_value
var is_editing : bool = false


func _ready() -> void:
	super._ready() 

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

	if is_editing:
		draw_text("pressione a tecla nova", value_pos, value_color, outline_value)
	else:
		draw_text(GameManager.char_from_key(value), value_pos, value_color, outline_value)

func _input(event: InputEvent) -> void:
	if is_editing:
		if event is InputEventKey:
			if event.pressed and not event.echo:
				value = event.physical_keycode
				is_editing = false 

				GameManager.change_setting(id, value)
				# print("definindo a input como " + GameManager.char_from_key(value) + " e desligando o modo edição")
				accept_event()
				queue_redraw()
				return
	
func _gui_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		# liga o modo de edicao
		# print("ligando o modo edição")
		is_editing = true
		queue_redraw()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_FOCUS_EXIT:
			is_editing = false
