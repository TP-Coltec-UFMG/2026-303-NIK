@tool
extends ConfigButton
class_name ConfigButtonFloat

@export var vertical : bool = false
@export var valor : float = 0:
	set(novo_valor):
		valor = clampf(novo_valor, valor_minimo, valor_maximo)
		if passo > 0:
			valor = snappedf(valor, passo)
		if line_edit:
			line_edit.text = str(valor)
		if slider:
			animacao_slider()
		if MestreSupremo: MestreSupremo.alterar_configuracao(id, valor)
@export var slider : bool = false
@export var valor_minimo : float = 0.0
@export var valor_maximo : float = 1.0
@export var passo : float = 0.1

var valor_normal : float:
	set(v):
		valor_normal = v
		queue_redraw()

var espacamento = 10.0

var line_edit : LineEdit

var editando : bool = false:
	set(v):
		editando = v
		queue_redraw()

var tween : Tween

func _ready() -> void:
	super._ready() 
	
	if not line_edit and not slider:
		line_edit = LineEdit.new()
		add_child(line_edit)
		
		line_edit.text = str(valor)
		
		line_edit.text_submitted.connect(_on_text_submitted)
		line_edit.focus_exited.connect(func(): _on_text_submitted(line_edit.text))

func _draw() -> void:
	var offset = desenha_texto(label)
	
	if line_edit and not slider:  # slider oculta o line edit
		if not vertical:
			line_edit.position = Vector2(offset.x + espacamento, (size.y - line_edit.size.y) / 2)
			line_edit.size.x = size.x - offset.x - 2 * espacamento
		else:
			line_edit.position = Vector2(0, size.y - 5)
			line_edit.size.x = size.x

	if slider:
		var expessura_barra = 16.0

		var cor_preenchimento = focus_color
		if has_focus() and editando: cor_preenchimento = alt_color
		
		var posicao_barra : Vector2 = Vector2(0, offset.y + espacamento)

		draw_rect(Rect2(posicao_barra + Vector2(1, 1), Vector2(valor_normal * size.x, expessura_barra - 2)), cor_preenchimento, true, -1, true)
		draw_style_box(get_theme_stylebox("normal", "LineEdit"), Rect2(Vector2(0, espacamento + offset.y), Vector2(size.x, expessura_barra)))
		draw_circle(Vector2(valor_normal * size.x, offset.y + espacamento + expessura_barra / 2), expessura_barra / 2 + 2, normal_color, true, -1, true)

		desenha_texto(str(valor), Vector2(size.x - tamanho_texto(str(valor)).x - 10.0, 0))

func animacao_slider() -> void:
	var alvo_normal = float(valor - valor_minimo) / float(valor_maximo - valor_minimo)
	
	if tween:
		tween.kill()
		
	tween = create_tween()
	
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(self, "valor_normal", alvo_normal, 0.1)

func _on_text_submitted(novo_texto: String) -> void:
	grab_focus()
	if novo_texto.is_valid_float():
		valor = novo_texto.to_float()
	else:
		line_edit.text = str(valor)

func _pressed() -> void:
	if not slider:
		line_edit.grab_focus() # quando apertado foca o texto
	# else:
	# 	editando = true

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_FOCUS_EXIT:
			editando = false # tira o editando se sair (na teoria nao precisa, mas é bom garantir)

func _gui_input(event: InputEvent) -> void:
	if editando:
		var mudou = false
		if event.is_action_pressed("ui_right"):
			valor += passo
			mudou = true
		elif event.is_action_pressed("ui_left"):
			valor -= passo
			mudou = true
			
		# nao deixa o godot passar o foco para outra configuracao
		if mudou or event.is_action_pressed("ui_up") or event.is_action_pressed("ui_down"):
			accept_event() 
			
	# alterna o modo de edicao
	if event.is_action_released("ui_accept"):
		editando = !editando
