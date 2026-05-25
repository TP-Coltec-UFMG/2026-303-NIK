# @tool
extends ConfigButton
class_name ConfigButtonKeybind

@export var vertical : bool = false
@export var input : String = "move_right"
@export var valor : Key:
	set(novo_valor):
		valor = novo_valor
		MestreSupremo.alterar_configuracao(id, valor)
var editando : bool = false


func _ready() -> void:
	super._ready() 

func _draw() -> void:
	var cor = get_theme_color("cor_normal", variacao_tema)
	var contorno = Color.TRANSPARENT
	
	if editando:
		cor = get_theme_color("cor_pressionado", variacao_tema)
		contorno = get_theme_color("cor_pressionado_contorno", variacao_tema)
	elif has_focus():
		cor = get_theme_color("cor_foco", variacao_tema)
		contorno = get_theme_color("cor_foco_contorno", variacao_tema)

	var offset
	offset = desenha_texto(label, Vector2.ZERO, cor, contorno)
	
	var cor_valor
	var contorno_valor
	if editando: 
		cor_valor = get_theme_color("cor_foco", variacao_tema)
		contorno_valor = get_theme_color("cor_foco_contorno", variacao_tema)
	else: 
		cor_valor = get_theme_color("cor_pressionado", variacao_tema)
		contorno_valor = get_theme_color("cor_pressionado_contorno", variacao_tema)

	var posicao_valor
	if not vertical:
		posicao_valor = Vector2(offset.x + 40, 0)
	else:
		posicao_valor = Vector2(0, offset.y)

	if editando:
		desenha_texto("pressione a tecla nova", posicao_valor, cor_valor, contorno_valor)
	else:
		desenha_texto(MestreSupremo.caractere_tecla(valor), posicao_valor, cor_valor, contorno_valor)

func _input(event: InputEvent) -> void:
	if editando:
		if event is InputEventKey:
			if event.pressed and not event.echo:
				valor = event.physical_keycode
				editando = false 
				print("definindo a entrada como " + MestreSupremo.caractere_tecla(valor) + " e desligando o modo edição")
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
