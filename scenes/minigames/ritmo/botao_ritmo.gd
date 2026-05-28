extends Control
class_name BotaoRitmo

class Nota:
	var ultima_posicao : float
	var posicao : float
	var valor : float

	func _init(_valor : float, _posicao : float) -> void:
		valor = _valor
		posicao = _posicao
		ultima_posicao = posicao

enum Tipo { CURA, ATAQUE, DEFESA }

@export var textura : Texture2D
@export var texture_nota : Texture2D
@export var textura_centro : Texture2D
@export var cor_texto : Color
@export var cor_contorno : Color
@export var tipo : Tipo = Tipo.CURA
@onready var tipo_string = "vida" if tipo == Tipo.CURA else ("ataque" if tipo == Tipo.ATAQUE else "defesa")
var notas : Array[Nota]

@onready var offset_centro = -textura.get_height() / 2.0

var tempo_nota = 1
@onready var velocidade = get_viewport_rect().size.y / tempo_nota


func _process(delta: float) -> void:
	for i in range(notas.size() -1, -1, -1):
		notas[i].posicao -= delta * get_viewport_rect().size.y
		notas[i].ultima_posicao = notas[i].posicao
		if notas[i].posicao < 0:
			notas.remove_at(i)

	if notas.size() > 0:
		queue_redraw()

		if Input.is_action_just_pressed("ritmo_" + tipo_string):
			clicar_nota()

func _draw() -> void:
	var tecla = MestreSupremo.acao_tecla("ritmo_" + tipo_string)

	desenhar_textura(textura_centro, Vector2(0, offset_centro))

	for nota in notas:
		desenhar_textura(texture_nota, Vector2(0, -nota.posicao - offset_centro))

	desenhar_textura(textura, Vector2.ZERO)

	var fonte = get_theme_font("font", "Button")
	var tamanho_fonte = get_theme_font_size("font_size", "Button") * 2

	var tamanho_do_texto = fonte.get_string_size(tecla, HORIZONTAL_ALIGNMENT_RIGHT, -1, tamanho_fonte)
	var posicao_texto = Vector2(textura.get_width() / 2.0 - tamanho_do_texto.x / 2, textura.get_height() - 12 + fonte.get_ascent(tamanho_fonte) + (size.y - tamanho_do_texto.y) / 2)

	draw_string_outline(fonte, posicao_texto, tecla, HORIZONTAL_ALIGNMENT_RIGHT, -1, tamanho_fonte, 30, cor_contorno)
	draw_string(fonte, posicao_texto, tecla, HORIZONTAL_ALIGNMENT_RIGHT, -1, tamanho_fonte, cor_texto)

func desenhar_textura(texture : Texture2D, posicao : Vector2):
	draw_texture_rect(texture, Rect2(posicao + size / 2 - texture.get_size() / 2, texture.get_size()), false)

func adicionar_nota(dano : float):
	notas.append(Nota.new(dano, get_viewport_rect().size.y))

func clicar_nota():
	var nota_mais_perto : Nota = notas[0]
	var menor_distancia : float = (notas[0].posicao + notas[0].ultima_posicao) / 2

	for nota in notas:
		if absf(nota.posicao) < menor_distancia:
			menor_distancia = absf((nota.posicao + nota.ultima_posicao) / 2)
			nota_mais_perto = nota

	notas.erase(nota_mais_perto)

	var valor_final = (nota_mais_perto.valor * 1.5) if (menor_distancia < get_process_delta_time() * velocidade) else (nota_mais_perto.valor) # considerando precisão
	match tipo:
		Tipo.CURA: 
			print("vida")
