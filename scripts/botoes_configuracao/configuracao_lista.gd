@tool
extends ConfigButtonBase
class_name ConfigButtonList

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
	
	var cor_do_valor = Color.WHITE if not editando else Color.PALE_TURQUOISE
	var offset_valor = desenha_texto(str(valor), Vector2(offset.x + 40, 0), cor_do_valor)
	if editando:
		var pontos = PackedVector2Array([
			Vector2(offset.x + 17 + 6, size.y / 2 + -6), 
			Vector2(offset.x + 17 + 6, size.y / 2 +  6), 
			Vector2(offset.x + 17,     size.y / 2)])
		draw_polygon(pontos, PackedColorArray([Color.PALE_TURQUOISE]))
		pontos = PackedVector2Array([
			Vector2(40 + offset.x + offset_valor.x + 17,     size.y / 2 + -6), 
			Vector2(40 + offset.x + offset_valor.x + 17,     size.y / 2 + 6), 
			Vector2(40 + offset.x + offset_valor.x + 17 + 6, size.y / 2)])
		draw_polygon(pontos, PackedColorArray([Color.PALE_TURQUOISE]))

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
