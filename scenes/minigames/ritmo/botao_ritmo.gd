extends Control
class_name BotaoRitmo

class Nota:
	var posicao : float: # nao a posicao literal, mas a posicao ele de 0 a 1, sendo 1 o topo da tela, 0 exatamente no botao, e negativo abaixo do botao
		set(valor):
			posicao = valor
	var valor : float
	var critico : bool

	func _init(_valor : float, _critico : bool = false) -> void:
		valor = _valor
		posicao = 1

		critico = _critico


enum Tipo { CURA, ATAQUE, DEFESA }

@onready var ritmo = get_parent().get_parent() as Ritmo

@export var textura : Texture2D
@export var texture_nota : Texture2D
@export var textura_centro : Texture2D
@export var cor_texto : Color
@export var cor_contorno : Color
@export var tipo : Tipo = Tipo.CURA
@onready var tipo_string = "vida" if tipo == Tipo.CURA else ("ataque" if tipo == Tipo.ATAQUE else "defesa")

@onready var posicao_inicial = position
var tween : Tween

const janela_acerto = 0.05
const janela_critico = 0.0075

signal acerto(valor : float, critico : bool)
signal erro(valor : float)

var notas : Array[Nota]

@onready var offset_centro = -textura.get_height() / 2.0

func _process(delta: float) -> void:
	if notas.is_empty(): return

	for i in range(notas.size() -1, -1, -1):
		notas[i].posicao -= delta
		if notas[i].posicao < -1:
			var nota = notas[i] 
			notas.remove_at(i)
			animacao_erro()

			if tipo == Tipo.DEFESA:
				ritmo.vida_nikole -= nota.valor
			if tipo == Tipo.ATAQUE:
				notas.clear() # encerra o ataque
				break

	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ritmo_" + tipo_string) and not notas.is_empty():
		clicar_nota()

func _draw() -> void:
	var tecla = MestreSupremo.acao_tecla("ritmo_" + tipo_string)

	desenhar_textura(textura_centro, Vector2(0, offset_centro))

	for nota in notas:
		var posicao_tela = get_viewport_rect().size.y * nota.posicao
		desenhar_textura(texture_nota, Vector2(0, -posicao_tela + offset_centro), Color(1, 0.2, 0.2, 1) if nota.critico else Color.WHITE)

	desenhar_textura(textura, Vector2.ZERO)

	var fonte = get_theme_font("font", "Button")
	var tamanho_fonte = get_theme_font_size("font_size", "Button") * 2

	var tamanho_do_texto = fonte.get_string_size(tecla, HORIZONTAL_ALIGNMENT_RIGHT, -1, tamanho_fonte)
	var posicao_texto = Vector2(textura.get_width() / 2.0 - tamanho_do_texto.x / 2, textura.get_height() - 12 + fonte.get_ascent(tamanho_fonte) + (size.y - tamanho_do_texto.y) / 2)

	draw_string_outline(fonte, posicao_texto, tecla, HORIZONTAL_ALIGNMENT_RIGHT, -1, tamanho_fonte, 30, cor_contorno)
	draw_string(fonte, posicao_texto, tecla, HORIZONTAL_ALIGNMENT_RIGHT, -1, tamanho_fonte, cor_texto)

func desenhar_textura(texture : Texture2D, posicao : Vector2, cor : Color = Color.WHITE):
	draw_texture_rect(texture, Rect2(posicao + size / 2 - texture.get_size() / 2, texture.get_size()), false, cor)

func adicionar_nota(valor : float):
	notas.append(Nota.new(valor))

func clicar_nota():
	var nota_mais_perto : Nota = notas[0]
	var menor_distancia : float = absf(notas[0].posicao)

	for nota in notas:
		if absf(nota.posicao) < menor_distancia:
			menor_distancia = absf(nota.posicao)
			nota_mais_perto = nota

	notas.erase(nota_mais_perto)

	var valor = nota_mais_perto.valor
	var acerto_critico = (menor_distancia < janela_critico)

	if menor_distancia > janela_acerto:
		erro.emit(valor)
		animacao_erro()
	else: 
		acerto.emit(valor, acerto_critico)
	queue_redraw()

func animacao_erro():
	var forca = 10

	if tween:
		tween.kill()
		
	tween = create_tween()
	
	for i in range(5):
		var offset = Vector2(randf_range(-forca, forca), randf_range(-forca, forca))
		tween.tween_property(self, "position", posicao_inicial + offset, 0.025)
	
	# Always return to the starting position at the end
	tween.tween_property(self, "position", posicao_inicial, 0.025)

	
