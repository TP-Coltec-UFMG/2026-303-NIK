# @tool
extends ConfigButton
class_name ConfigButtonString

@export var vertical : bool = false
@export var value : String = "":
	set(new_value):
		value = new_value
		if line_edit:
			line_edit.text = new_value

var line_edit : LineEdit

func _ready() -> void:
	super._ready() 
	
	if not line_edit:
		line_edit = LineEdit.new()
		add_child(line_edit)
		
		line_edit.text = str(value)
		
		line_edit.text_submitted.connect(_on_text_submitted)
		line_edit.focus_exited.connect(func(): _on_text_submitted(line_edit.text))

func _draw() -> void:
	var offset = draw_text(label)
	
	if line_edit:
		var gap = 10.0
		
		if not vertical:
			line_edit.position = Vector2(offset.x + gap, (size.y - line_edit.size.y) / 2)
			line_edit.size.x = size.x - offset.x - 2 * gap
		else:
			line_edit.position = Vector2(0, size.y - 5)
			line_edit.size.x = size.x

func _on_text_submitted(new_text: String) -> void:
	grab_focus()
	value = new_text
		
	GameManager.change_setting(id, value)

func _pressed() -> void:
	line_edit.grab_focus() # quando apertado foca o texto