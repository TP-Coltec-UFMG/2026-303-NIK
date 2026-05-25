# @tool
extends ConfigButton
class_name ConfigButtonBool

@export var vertical : bool = false
@export var valor : bool = false:
	set(novo_valor):
		valor = novo_valor
		MestreSupremo.alterar_configuracao(id, valor)

func _ready() -> void:
	super._ready() 

func _draw() -> void:
	var cor = get_theme_color("cor_normal", variacao_tema)
	var contorno = Color.TRANSPARENT
	
	if has_focus():
		cor = get_theme_color("cor_foco", variacao_tema)
		contorno = get_theme_color("cor_foco_contorno", variacao_tema)

	var offset = desenha_texto(label, Vector2.ZERO, cor, contorno)

	var posicao_valor
	var cor_valor
	var contorno_valor
	if vertical:
		posicao_valor = Vector2(0, offset.y - 5)
	else:
		posicao_valor = Vector2(offset.x + 10, 0)

	if valor:
		cor_valor = get_theme_color("cor_pressionado", variacao_tema)
		contorno_valor = get_theme_color("cor_pressionado_contorno", variacao_tema)
	else:
		cor_valor = get_theme_color("cor_foco", variacao_tema)
		contorno_valor = get_theme_color("cor_foco_contorno", variacao_tema)

	desenha_texto("ligado" if valor else "desligado", posicao_valor, cor_valor, contorno_valor)

func _pressed() -> void:
	valor = !valor
