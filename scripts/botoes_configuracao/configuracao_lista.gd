@tool
extends ConfigButton
class_name ConfigButtonList

@export var vertical : bool = false
@export var valores : Array[String] = ["preciso de valores :("]
@export var valor = "ay cabron"
var _valor : int = 0:
	set(valor_novo):
		if valores.size() > 0:
			_valor = (valor_novo + valores.size()) % valores.size()
			valor = valores[_valor]
		else:
			_valor = 0
		queue_redraw()

var editando = false:
	set(v):
		editando = v
		queue_redraw()

func _ready() -> void:
	super._ready() 
	_valor = 0

func _draw() -> void:
	var offset
	if editando and pressed:
		offset = desenha_texto(label, Vector2.ZERO, focus_color)
	else: offset = desenha_texto(label)
	
	var cor_valor
	var contorno_valor
	if editando: 
		cor_valor = pressed_color
		contorno_valor = focus_color
	else: 
		cor_valor = normal_color
		contorno_valor = focus_color

	var posicao_valor
	if not vertical:
		posicao_valor = Vector2(offset.x + 40, 0)
	else:
		posicao_valor = Vector2(0, offset.y)

	var offset_valor = desenha_texto(str(valor), posicao_valor, cor_valor, contorno_valor)
	if editando:
		var font = get_theme_font("font", "Button")
		var font_size = get_theme_font_size("font_size", "Button")

		var tamanho_seta = font.get_string_size("<", HORIZONTAL_ALIGNMENT_CENTER, -1, font_size)
		if not vertical:
			desenha_texto("<", Vector2((posicao_valor.x + 20) - tamanho_seta.x / 2, 0), cor_valor, contorno_valor)
			desenha_texto(">", Vector2((posicao_valor.x + offset_valor.x + 40 + 20) - tamanho_seta.x / 2, 0), cor_valor, contorno_valor)
		else:
			desenha_texto("<", Vector2(-tamanho_seta.x / 2 - 20, posicao_valor.y), cor_valor, contorno_valor)
			desenha_texto(">", Vector2((offset_valor.x + 40 + 20) - tamanho_seta.x / 2 - 40, posicao_valor.y), cor_valor, contorno_valor)

func _gui_input(event: InputEvent) -> void:
	if editando:
		var mudou = false
		if event.is_action_pressed("ui_right"):
			_valor += 1
			mudou = true
		elif event.is_action_pressed("ui_left"):
			_valor -= 1
			mudou = true
			
		# nao deixa o godot passar o foco para outra configuracao
		if mudou or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
			accept_event() 
			
	# alterna o modo de edicao
	if event.is_action_released("ui_accept"):
		editando = !editando

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_FOCUS_EXIT:
			editando = false # tira o editando se sair (na teoria nao precisa, mas é bom garantir)

# func _pressed() -> void:
# 	editando = !editando # Alterna a edição do valor
