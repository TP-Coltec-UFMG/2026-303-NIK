@tool
extends ConfigButton
class_name ConfigButtonKeybind

@export var vertical : bool = false
@export var input : String = "move_right"
@export var valor : Key:
	set(novo_valor):
		valor = novo_valor
var editando : bool = false


func _ready() -> void:
	super._ready() 

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

	if editando:
		desenha_texto("pressione a tecla nova", posicao_valor, cor_valor, contorno_valor)
	else:
		desenha_texto(str(OS.get_keycode_string(valor)), posicao_valor, cor_valor, contorno_valor)

func _input(event: InputEvent) -> void:
	if editando:
		if event is InputEventKey:
			if event.pressed and not event.echo:
				valor = event.physical_keycode
				editando = false 
				print("definindo a entrada como " + str(OS.get_keycode_string(valor)) + " e desligando o modo edição")
				accept_event()
				queue_redraw()
				return
	
func _gui_input(event: InputEvent) -> void:
	if event.is_action_released("ui_accept"):
		# liga o modo de edicao
		print("ligando o modo edição")
		editando = true
		queue_redraw()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_FOCUS_EXIT:
			editando = false