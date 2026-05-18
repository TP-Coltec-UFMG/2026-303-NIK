@tool
extends BaseButton
class_name DialogButton

@export var label : String = ""
@export var normal_color : Color = Color.PALE_GOLDENROD
@export var focus_color : Color = Color.LIGHT_GOLDENROD
@export var pressed_color : Color = Color.GOLDENROD
var proxima_arvore : String = ""
var tags_adicionar : Array[String]

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL

func _draw() -> void:
	var tamanho = desenha_texto(label)
	custom_minimum_size.y = tamanho.y

func _notification(what: int) -> void:
	if what == NOTIFICATION_MOUSE_ENTER:
		grab_focus()

func desenha_texto(texto : String, offset : Vector2 = Vector2(16, 0), cor = null, contorno = null) -> Vector2:
	var tem_foco = has_focus() or (get_viewport().gui_get_focus_owner() in get_children()) # ve se ta focado ele ou um bebê dele

	var current_color = normal_color
	if is_pressed():
		current_color = pressed_color
	elif tem_foco:
		current_color = focus_color
	if label.is_empty():
		return Vector2.ZERO

	if cor:
		current_color = cor

	# configura a fonte pra funcionar com o tema
	var font = get_theme_font("font", "Button")
	var font_size = get_theme_font_size("font_size", "Button")

	var text_size = font.get_string_size(texto, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size)
	var text_position = offset + Vector2(0, font.get_ascent(font_size) + (size.y - text_size.y) / 2)

	var outline_color
	if tem_foco:
		outline_color = pressed_color
		if is_pressed(): outline_color = focus_color
		if contorno:
			outline_color = contorno
	
	if outline_color: draw_string_outline(font, text_position, texto, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size, 10, outline_color)
	draw_string(font, text_position, texto, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size, current_color)

	return Vector2(text_size.x, text_size.y) # retorna a posicao em que o texto acabou

func _pressed() -> void:
	Dialogo.adicionar_tags(tags_adicionar)
		
	Dialogo.iniciar_dialogo(proxima_arvore)