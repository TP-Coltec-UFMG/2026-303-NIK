class_name Menu extends Control

class MenuData:
	var node : Control
	var objects : Array
	var buttons : Array[ConfigButton]
	var active_idx : int = 0
	var keep_idx : bool = false

	func _init(_node : Control, _objects : Array, _buttons : Array[ConfigButton], _keep_idx : bool = false):
		node = _node
		objects = _objects
		buttons = _buttons
		keep_idx = _keep_idx

@export var pages : Dictionary[String, VBoxContainer] = {}

@export var setting_buttons : Array = []

## Configurações do Menu Circular ##
var circular_menu : bool = true:
	set(value):
		circular_menu = value
		update_circular_buttons(-1)
		

# Índice da opção do menu atual
var current_idx : int = 0
# "Índice" da posição opção do menu atual 
var current_position : int = 0

# Dicionário com todos os menus e seus botões
var menus : Dictionary = {}
var active_menu : String = "Principal"

# Tamanho do raio da circunferência do Menu
const base_menu_radius : int = 1000
var menu_radius : int = 1000

# Distância do meio da circunferência do Menu pro meio da tela
const menu_center_offset : Vector2 = Vector2(1000, 0);

# Ângulo, em radiano, entre os botões
const menu_angle : float = 0.1
# Distância, em pixels, entre os botões 
const menu_distance : float = 64

# Distância do botão selecionado da circunferência
const selected_button_offset : float = 0

# Escala do botão selecionado
const selected_button_scale : float = 1.0

# Ângulo inicial do menu
const start_angle : float = PI # centralizado

func _ready() -> void:
	close_pages()
	setup_menus()
	setup_circular_buttons()

	for button in $Telas/Configuracoes.get_children():
		if button is ConfigButton and "value" in button:
			setting_buttons.append(button)
	for button in $Telas/Acessibilidade.get_children():
		if button is ConfigButton and "value" in button:
			setting_buttons.append(button)
	for button in $Telas/Controles.get_children():
		if button is ConfigButton and "value" in button:
			setting_buttons.append(button)

	# load_settings()
	
	# abrir_tela("Principal")

# Função chamada a cada frame
func _process(delta: float) -> void:
	# Atualiza os botões do menu principal
	update_circular_buttons(delta)

"""
Atualiza a posição dos botões em uma organização circular a lista de botões dado 
@param menu_data estrutura com os dados do menu ativo
"""
func update_circular_buttons(delta : float):
	var menu_data = menus[active_menu]
	var lista_botoes = menu_data.buttons
	var lista_objetos = menu_data.objects

	# Atualiza o index para apontar para o button com foco
	current_idx = buscar_foco(lista_botoes)
	current_position = lista_objetos.find(lista_botoes[current_idx])

	# Percorre todos os botões, definindo a posição de cada um
	for i in range(lista_objetos.size()):
		var button : Control = lista_objetos[i]

		# Índice relativo à opção selecionada atualmente
		var idx_relativo : int = i - current_position

		# Obtém o fator da escala para diminuir os botões mais distantes e aumentar o botão selecionado
		var fator_escala : float = (selected_button_scale if idx_relativo == 0 else 1.0) * pow(.8, abs(idx_relativo))
		
		# Aplica o fator_escala no botão
		button.scale = lerp(button.scale, Vector2(fator_escala, fator_escala), (delta / 0.1) if delta > 0 else 1.0)

		# Diminui a opacidade dos botões distantes
		var opacidade = clampf(1.0 - max(0, abs(idx_relativo) - 2) * 0.34, 0, 1)
		button.modulate.a = lerp(button.modulate.a, opacidade, (delta / 0.1)  if delta > 0 else 1.0)

	# Gira a tela inteira para deixar o button selecionado na esquerda
	var angulo : float = current_position * menu_angle * get_tree().root.content_scale_factor
	var posicao : Vector2 = get_viewport_rect().size / 2 + menu_center_offset / get_tree().root.content_scale_factor

	if not circular_menu: 
		angulo = 0
		posicao.y -= current_position * menu_distance

	$Telas.rotation = lerp($Telas.rotation, angulo, (delta / 0.1) if delta > 0 else 1.0)
	$Telas.position = lerp($Telas.position, posicao, (delta / 0.1) if delta > 0 else 1.0)
	
	$Ponteiro.label_settings.outline_color = lerp($Ponteiro.label_settings.outline_color, get_theme_color("cor_foco_contorno", lista_botoes[current_idx].variacao_tema), (delta / 0.1) if delta > 0 else 1.0)
	$Ponteiro.label_settings.font_color = lerp($Ponteiro.label_settings.font_color, get_theme_color("cor_foco", lista_botoes[current_idx].variacao_tema), (delta / 0.1) if delta > 0 else 1.0)
	
	if not circular_menu: 
		$Ponteiro.position.x = lerp($Ponteiro.position.x, (get_viewport_rect().size.x / 2 + menu_center_offset.x - base_menu_radius - 20) - 20 * sin(abs($Telas.position.y - posicao.y) / menu_distance), (delta / 0.05) if delta > 0 else 1.0)
	else:
		$Ponteiro.position.x = lerp($Ponteiro.position.x, (get_viewport_rect().size.x / 2 + menu_center_offset.x - base_menu_radius - 20) - 20 * sin(abs($Telas.rotation - angulo) / (menu_angle * get_tree().root.content_scale_factor)), (delta / 0.05) if delta > 0 else 1.0)
	$Ponteiro.position.y = get_viewport_rect().size.y / 2 + menu_center_offset.y - (10 if circular_menu else 8) 

func setup_circular_buttons():
	menu_radius = int(base_menu_radius / get_tree().root.content_scale_factor)
	
	# Percorre todos os botões, definindo a posição de cada um
	for menu in menus.values():
		for i in range(menu.objects.size()):
			var objeto : Control = menu.objects[i]

			var angulo : float = (i * menu_angle * get_tree().root.content_scale_factor) - start_angle
			if objeto is Label:
				angulo += menu_angle * get_tree().root.content_scale_factor / 2

			# Calcula e define a posição do botão
			var x : float = (cos(angulo) * menu_radius)
			var y : float = -(sin(angulo) * menu_radius)
			
			if not circular_menu: 
				x = -menu_radius
				y = i * menu_distance
				angulo = -PI
			objeto.position = Vector2(x, y)
			# Aponta o botão para o centro do círculo
			objeto.rotation = PI - angulo

func buscar_foco(lista_botoes : Array) -> int:
	for i in range(lista_botoes.size()):
		var button : ConfigButton = lista_botoes[i]
		if button.has_focus():
			return i
	return current_idx

func abrir_tela(alvo : String):
	print("carregando tela \"" + alvo + "\"")
	if alvo in menus.keys():
		for menu in menus.keys():
			if menu == alvo:
				current_idx = menus[menu].active_idx if menus[menu].keep_idx else 0
				current_position = menus[menu].objects.find(menus[menu].buttons[current_idx])
				active_menu = menu
				menus[menu].buttons[current_idx].grab_focus()
				menus[menu].node.visible = true
				visible = true
				get_tree().paused = true
				
				# vai imediatamente para a posição do menu novo
				var posicao : Vector2 = get_viewport_rect().size / 2 + menu_center_offset / get_tree().root.content_scale_factor
				var angulo : float = current_position * menu_angle * get_tree().root.content_scale_factor
				
				if not circular_menu:
					angulo = 0
					posicao.y -= (current_position) * menu_distance

				$Telas.position = posicao
				$Telas.rotation = angulo
				update_circular_buttons(-1)
			else:
				menus[menu].node.visible = false
	else:
		print("tela \"" + alvo + "\" não existe!!!")

func close_pages():
	visible = false
	get_tree().paused = false
	for menu in menus.values():
		menu.node.visible = false

func load_settings() -> void:
	var settings = GameManager.settings
	for button in setting_buttons:
		if button.id in settings:
			if button.value != settings[button.id]:
				if not button is ConfigButtonList:
					button.value = settings[button.id]
				else:
					if settings[button.id] in button.valores:
						button._valor = button.valores.find(settings[button.id])
					else: button._valor = 0

# Função chamada quando há alguma input do usuário
func _input(event: InputEvent) -> void:
	if not get_tree().paused: 
		if event.is_action_pressed("pausar"):
			abrir_tela("Principal")
	# A opção atual aumenta (positivo) quando aperta para baixo e
	# diminui (negativo) quando aperta para cima
	if visible == true and (event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up")):
		current_idx += int(event.is_action_pressed("ui_down")) - int(event.is_action_pressed("ui_up"));
		current_idx = (current_idx + menus[active_menu].buttons.size()) % menus[active_menu].buttons.size()
		menus[active_menu].buttons[current_idx].grab_focus()
		menus[active_menu].active_idx = current_idx
		accept_event()
func setup_menus():
	
	# PRINCIPAL

	menus["Principal"] = MenuData.new($Telas/Principal, [], [], true)

	$Telas/Principal/BotaoJogar.connect("pressed", close_pages)
	$Telas/Principal/BotaoConfiguracoes.connect("pressed", abrir_tela.bind("Configuracoes"))
	$Telas/Principal/BotaoAcessibilidade.connect("pressed", abrir_tela.bind("Acessibilidade"))
	$Telas/Principal/BotaoSalvar.connect("pressed", GameManager.save_game)
	$Telas/Principal/BotaoSair.connect("pressed", get_tree().quit)

	for filho in $Telas/Principal.get_children():
		if filho is ConfigButton:
			menus["Principal"].buttons.append(filho)
			filho.size.x = 300
		menus["Principal"].objects.append(filho)

	# CONFIGURAÇÕES
			
	menus["Configuracoes"] = MenuData.new($Telas/Configuracoes, [], [], true)
	for filho in $Telas/Configuracoes.get_children():
		if filho is ConfigButton:
			menus["Configuracoes"].buttons.append(filho)
			filho.size.x = 300
		menus["Configuracoes"].objects.append(filho)

	$Telas/Configuracoes/BotaoSalvar.connect("pressed", func():
		save_settings()
		menus["Configuracoes"].active_idx = 0
		abrir_tela("Principal")
	)
	$Telas/Configuracoes/BotaoControles.connect("pressed", abrir_tela.bind("Controles"))

	# ACESSIBILIDADE

	menus["Acessibilidade"] = MenuData.new($Telas/Acessibilidade, [], [])
	for filho in $Telas/Acessibilidade.get_children():
		if filho is ConfigButton:
			menus["Acessibilidade"].buttons.append(filho)
			filho.size.x = 300
		menus["Acessibilidade"].objects.append(filho)

	$Telas/Acessibilidade/BotaoSalvar.connect("pressed", func():
		save_settings()
		abrir_tela("Principal")
	)

	# CONTROLES

	menus["Controles"] = MenuData.new($Telas/Controles, [], [])
	for filho in $Telas/Controles.get_children():
		if filho is ConfigButton:
			menus["Controles"].buttons.append(filho)
			filho.size.x = 300
		menus["Controles"].objects.append(filho)

	$Telas/Controles/BotaoSalvar.connect("pressed", func():
		save_settings()
		abrir_tela("Configuracoes")
	)

func save_settings() -> void:
	GameManager.save_settings()
