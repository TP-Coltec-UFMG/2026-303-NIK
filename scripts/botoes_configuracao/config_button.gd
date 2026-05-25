# @tool
extends BaseButton
class_name ConfigButton

@export var id : String = "id_único!!!"
@export var label : String = "oii, eu sou uma configuracao!!"

@export var variacao_tema : String = "ConfigButton"

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL



func _draw() -> void:
	desenha_texto(label)

func desenha_texto(texto : String, offset : Vector2 = Vector2.ZERO, cor = null, contorno = null) -> Vector2:
	var tem_foco = has_focus() or (get_viewport().gui_get_focus_owner() in get_children()) # ve se ta focado ele ou um bebê dele

	var cor_texto = get_theme_color("cor_normal", variacao_tema)
	if not cor: # aplica a cor correta pro texto
		if is_pressed():
			cor_texto = get_theme_color("cor_pressionado", variacao_tema)
		elif tem_foco:
			cor_texto = get_theme_color("cor_foco", variacao_tema)
		if label.is_empty():
			return Vector2.ZERO
	else:
		cor_texto = cor

	var cor_contorno
	if tem_foco: # aplica a cor correta pro contorno
		if contorno:
			cor_contorno = contorno
		else:
			if not pressed:
				cor_contorno = get_theme_color("cor_foco_contorno", variacao_tema)
			else:
				cor_contorno = get_theme_color("cor_pressionado_contorno", variacao_tema)

	# configura a fonte pra funcionar com o tema
	var fonte = get_theme_font("font", "Button")
	var tamanho_fonte = get_theme_font_size("font_size", "Button")

	var tamanho_do_texto = fonte.get_string_size(texto, HORIZONTAL_ALIGNMENT_RIGHT, -1, tamanho_fonte)
	var posicao_texto = offset + Vector2(0, fonte.get_ascent(tamanho_fonte) + (size.y - tamanho_do_texto.y) / 2)

	if tem_foco:
		cor_contorno = get_theme_color("cor_foco_contorno", variacao_tema)
		if is_pressed(): cor_contorno = get_theme_color("cor_pressionado_contorno", variacao_tema)
		if contorno:
			cor_contorno = contorno
	
	if cor_contorno: draw_string_outline(fonte, posicao_texto, texto, HORIZONTAL_ALIGNMENT_RIGHT, -1, tamanho_fonte, 10, cor_contorno)
	draw_string(fonte, posicao_texto, texto, HORIZONTAL_ALIGNMENT_RIGHT, -1, tamanho_fonte, cor_texto)

	return tamanho_do_texto # retorna a posicao em que o texto acabou

func tamanho_texto(texto : String):
	var font = get_theme_font("font", "Button")
	var font_size = get_theme_font_size("font_size", "Button")

	var text_size = font.get_string_size(texto, HORIZONTAL_ALIGNMENT_RIGHT, -1, font_size)
	return text_size
