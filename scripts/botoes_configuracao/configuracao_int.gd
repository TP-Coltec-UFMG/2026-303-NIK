@tool
extends ConfigButton
class_name ConfigButtonInt

@export var vertical : bool = false
@export var valor : int = 0:
	set(novo_valor):
		valor = clamp(novo_valor, valor_minimo, valor_maximo)
		if line_edit:
			line_edit.text = str(valor)
@export var valor_minimo : int = 0
@export var valor_maximo : int = 1

var line_edit : LineEdit

func _ready() -> void:
	super._ready() 
	
	if not line_edit:
		line_edit = LineEdit.new()
		add_child(line_edit)
		
		line_edit.text = str(valor)
		
		line_edit.text_submitted.connect(_on_text_submitted)
		line_edit.focus_exited.connect(func(): _on_text_submitted(line_edit.text))

func _draw() -> void:
	var offset = desenha_texto(label)
	
	if line_edit:
		var espacamento = 10.0
		
		if not vertical:
			line_edit.position = Vector2(offset.x + espacamento, (size.y - line_edit.size.y) / 2)
			line_edit.size.x = size.x - offset.x - 2 * espacamento
		else:
			line_edit.position = Vector2(0, size.y - 5)
			line_edit.size.x = size.x

func _on_text_submitted(novo_texto: String) -> void:
	grab_focus()
	if novo_texto.is_valid_int():
		valor = novo_texto.to_int()
	else:
		line_edit.text = str(valor)

func _pressed() -> void:
	line_edit.grab_focus() # quando apertado foca o texto
