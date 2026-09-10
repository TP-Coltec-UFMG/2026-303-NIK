# @tool
extends ConfigButton
class_name ConfigButtonInt

@export var vertical : bool = false
@export var value : int = 0:
	set(new_value):
		value = clamp(new_value, min_value, max_value)
		if step > 0:
			value = snappedi(value, step)
		if line_edit:
			line_edit.text = str(value)
		if slider:
			normal_value = float(value - min_value) / float(max_value - min_value)
@export var slider : bool = false
@export var min_value : int = 0
@export var max_value : int = 100
@export var step : int = 1

var gap = 10.0

var normal_value : float:
	set(v):
		normal_value = v
		slider_animation()

var slider_position : float:
	set(value):
		slider_position = value
		queue_redraw()


var tween : Tween

var line_edit : LineEdit

var is_editing : bool = false:
	set(v):
		is_editing = v
		queue_redraw()

func _ready() -> void:
	super._ready() 
	
	if not line_edit and not slider:
		line_edit = LineEdit.new()
		add_child(line_edit)
		
		line_edit.text = str(value)
		
		line_edit.text_submitted.connect(_on_text_submitted)
		line_edit.focus_exited.connect(func(): _on_text_submitted(line_edit.text))

func _draw() -> void:
	var color = get_theme_color("color_default", theme_variation)
	var outline = Color.TRANSPARENT
	
	if is_editing:
		color = get_theme_color("color_pressed", theme_variation)
		outline = get_theme_color("color_pressed_outline", theme_variation)
	elif has_focus():
		color = get_theme_color("color_focus", theme_variation)
		outline = get_theme_color("color_focus_outline", theme_variation)

	var offset = draw_text(label, Vector2.ZERO, color, outline)
	
	if line_edit and not slider:  # slider oculta o line edit
		if not vertical:
			line_edit.position = Vector2(offset.x + gap, (size.y - line_edit.size.y) / 2)
			line_edit.size.x = size.x - offset.x - 2 * gap
		else:
			line_edit.position = Vector2(0, size.y - 5)
			line_edit.size.x = size.x

	if slider:
		var bar_width = 16.0
		var fill_color = get_theme_color("color_focus", theme_variation)
		if is_editing: fill_color = get_theme_color("color_pressed", theme_variation)
		
		var bar_position : Vector2 = Vector2(0, offset.y + gap)

		draw_rect(Rect2(bar_position + Vector2(1, 1), Vector2(slider_position * size.x, bar_width - 2)), fill_color, true, -1, true)
		draw_style_box(get_theme_stylebox("normal", "LineEdit"), Rect2(Vector2(0, gap + offset.y), Vector2(size.x, bar_width)))
		draw_circle(Vector2(slider_position * size.x, offset.y + gap + bar_width / 2), bar_width / 2 + 2, get_theme_color("color_default", theme_variation), true, -1, true)

		draw_text(str(value), Vector2(size.x - text_size(str(value)).x - 10.0, 0), color, outline)

func slider_animation() -> void:
	var target_normal = float(value - min_value) / float(max_value - min_value)
	
	if tween:
		tween.kill()
		
	tween = create_tween()
	
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "slider_position", target_normal, 0.1)
	
func _on_text_submitted(new_text: String) -> void:
	grab_focus()
	if new_text.is_valid_int():
		value = new_text.to_int()
	else:
		line_edit.text = str(value)

func _pressed() -> void:
	if not slider:
		line_edit.grab_focus() # quando apertado foca o texto
	# else:
	# 	is_editing = true

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_FOCUS_EXIT:
			is_editing = false # tira o is_editing se sair (na teoria nao precisa, mas é bom garantir)

func _gui_input(event: InputEvent) -> void:
	if is_editing:
		var changed = false
		if event.is_action_pressed("ui_right"):
			value += step
			changed = true
		elif event.is_action_pressed("ui_left"):
			value -= step
			changed = true
			
		# nao deixa o godot passar o foco para outra configuracao
		if changed or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
			accept_event() 
		
		if changed:
			GameManager.change_setting(id, value)
			
	# alterna o modo de edicao
	if event.is_action_released("ui_accept"):
		is_editing = !is_editing
