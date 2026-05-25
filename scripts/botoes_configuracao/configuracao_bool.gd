@tool
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
	var offset = desenha_texto(label)

	var posicao_valor
	var cor_valor
	var contorno_valor
	if vertical:
		posicao_valor = Vector2(0, offset.y - 5)
	else:
		posicao_valor = Vector2(offset.x + 10, 0)

	if valor:
		cor_valor = alt_color
		contorno_valor = focus_color
	else:
		cor_valor = focus_color
		contorno_valor = alt_color

	desenha_texto("ligado" if valor else "desligado", posicao_valor, cor_valor, contorno_valor)

func _pressed() -> void:
	valor = !valor
