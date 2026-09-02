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
var active_menu : String = "Main"

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

	for button in $Pages/Settings.get_children():
		if button is ConfigButton and "value" in button:
			setting_buttons.append(button)
	for button in $Pages/Accessibility.get_children():
		if button is ConfigButton and "value" in button:
			setting_buttons.append(button)
	for button in $Pages/Controls.get_children():
		if button is ConfigButton and "value" in button:
			setting_buttons.append(button)

	# load_settings()
	
	# open_screen("Main")

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
	var button_list = menu_data.buttons
	var object_list = menu_data.objects

	# Atualiza o index para apontar para o button com foco
	current_idx = search_focus(button_list)
	current_position = object_list.find(button_list[current_idx])

	# Percorre todos os botões, definindo a posição de cada um
	for i in range(object_list.size()):
		var button : Control = object_list[i]

		# Índice relativo à opção selecionada atualmente
		var relative_idx : int = i - current_position

		# Obtém o fator da escala para diminuir os botões mais distantes e aumentar o botão selecionado
		var scale_factor : float = (selected_button_scale if relative_idx == 0 else 1.0) * pow(.8, abs(relative_idx))
		
		# Aplica o fator_escala no botão
		button.scale = lerp(button.scale, Vector2(scale_factor, scale_factor), (delta / 0.1) if delta > 0 else 1.0)

		# Diminui a opacidade dos botões distantes
		var alpha = clampf(1.0 - max(0, abs(relative_idx) - 2) * 0.34, 0, 1)
		button.modulate.a = lerp(button.modulate.a, alpha, (delta / 0.1)  if delta > 0 else 1.0)

	# Gira a tela inteira para deixar o button selecionado na esquerda
	var ang : float = current_position * menu_angle * get_tree().root.content_scale_factor
	var pos : Vector2 = get_viewport_rect().size / 2 + menu_center_offset / get_tree().root.content_scale_factor

	if not circular_menu: 
		ang = 0
		pos.y -= current_position * menu_distance

	$Pages.rotation = lerp($Pages.rotation, ang, (delta / 0.1) if delta > 0 else 1.0)
	$Pages.position = lerp($Pages.position, pos, (delta / 0.1) if delta > 0 else 1.0)
	
	$Pointer.label_settings.outline_color = lerp($Pointer.label_settings.outline_color, get_theme_color("color_focus_outline", button_list[current_idx].theme_variation), (delta / 0.1) if delta > 0 else 1.0)
	$Pointer.label_settings.font_color = lerp($Pointer.label_settings.font_color, get_theme_color("color_focus", button_list[current_idx].theme_variation), (delta / 0.1) if delta > 0 else 1.0)
	
	if not circular_menu: 
		$Pointer.position.x = lerp($Pointer.position.x, (get_viewport_rect().size.x / 2 + menu_center_offset.x - base_menu_radius - 20) - 20 * sin(abs($Pages.position.y - pos.y) / menu_distance), (delta / 0.05) if delta > 0 else 1.0)
	else:
		$Pointer.position.x = lerp($Pointer.position.x, (get_viewport_rect().size.x / 2 + menu_center_offset.x - base_menu_radius - 20) - 20 * sin(abs($Pages.rotation - ang) / (menu_angle * get_tree().root.content_scale_factor)), (delta / 0.05) if delta > 0 else 1.0)
	$Pointer.position.y = get_viewport_rect().size.y / 2 + menu_center_offset.y - (10 if circular_menu else 8) 

func setup_circular_buttons():
	menu_radius = int(base_menu_radius / get_tree().root.content_scale_factor)
	
	# Percorre todos os botões, definindo a posição de cada um
	for menu in menus.values():
		for i in range(menu.objects.size()):
			var object : Control = menu.objects[i]

			var ang : float = (i * menu_angle * get_tree().root.content_scale_factor) - start_angle
			if object is Label:
				ang += menu_angle * get_tree().root.content_scale_factor / 2

			# Calcula e define a posição do botão
			var x : float = (cos(ang) * menu_radius)
			var y : float = -(sin(ang) * menu_radius)
			
			if not circular_menu: 
				x = -menu_radius
				y = i * menu_distance
				ang = -PI
			object.position = Vector2(x, y)
			# Aponta o botão para o centro do círculo
			object.rotation = PI - ang

func search_focus(button_list : Array) -> int:
	for i in range(button_list.size()):
		var button : ConfigButton = button_list[i]
		if button.has_focus():
			return i
	return current_idx

func open_screen(target : String):
	print("loading page \"" + target + "\"")
	if target in menus.keys():
		for menu in menus.keys():
			if menu == target:
				current_idx = menus[menu].active_idx if menus[menu].keep_idx else 0
				current_position = menus[menu].objects.find(menus[menu].buttons[current_idx])
				active_menu = menu
				menus[menu].buttons[current_idx].grab_focus()
				menus[menu].node.visible = true
				visible = true
				get_tree().paused = true
				
				# vai imediatamente para a posição do menu novo
				var pos : Vector2 = get_viewport_rect().size / 2 + menu_center_offset / get_tree().root.content_scale_factor
				var ang : float = current_position * menu_angle * get_tree().root.content_scale_factor
				
				if not circular_menu:
					ang = 0
					pos.y -= (current_position) * menu_distance

				$Pages.position = pos
				$Pages.rotation = ang
				update_circular_buttons(-1)
			else:
				menus[menu].node.visible = false
	else:
		print("page \"" + target + "\" does not exist!!!")

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
					if settings[button.id] in button.values:
						button._value = button.values.find(settings[button.id])
					else: button._value = 0

# Função chamada quando há alguma input do usuário
func _input(event: InputEvent) -> void:
	if not get_tree().paused: 
		if event.is_action_pressed("pause"):
			open_screen("Main")
	# A opção atual aumenta (positivo) quando aperta para baixo e
	# diminui (negativo) quando aperta para cima
	if visible == true and (event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up")):
		current_idx += int(event.is_action_pressed("ui_down")) - int(event.is_action_pressed("ui_up"));
		current_idx = (current_idx + menus[active_menu].buttons.size()) % menus[active_menu].buttons.size()
		menus[active_menu].buttons[current_idx].grab_focus()
		menus[active_menu].active_idx = current_idx
		accept_event()

func setup_menus():
	
	# MAIN

	menus["Main"] = MenuData.new($Pages/Main, [], [], true)

	$Pages/Main/ButtonPlay.connect("pressed", close_pages)
	$Pages/Main/ButtonSettings.connect("pressed", open_screen.bind("Settings"))
	$Pages/Main/ButtonAccessibility.connect("pressed", open_screen.bind("Accessibility"))
	$Pages/Main/ButtonSave.connect("pressed", GameManager.save_game)
	$Pages/Main/ButtonQuit.connect("pressed", get_tree().quit)

	for child in $Pages/Main.get_children():
		if child is ConfigButton:
			menus["Main"].buttons.append(child)
			child.size.x = 300
		menus["Main"].objects.append(child)

	# SETTINGS
			
	menus["Settings"] = MenuData.new($Pages/Settings, [], [], true)
	for child in $Pages/Settings.get_children():
		if child is ConfigButton:
			menus["Settings"].buttons.append(child)
			child.size.x = 300
		menus["Settings"].objects.append(child)

	$Pages/Settings/ButtonSave.connect("pressed", func():
		save_settings()
		menus["Settings"].active_idx = 0
		open_screen("Main")
	)
	$Pages/Settings/ButtonControls.connect("pressed", open_screen.bind("Controls"))

	# ACCESSIBILITY

	menus["Accessibility"] = MenuData.new($Pages/Accessibility, [], [])
	for child in $Pages/Accessibility.get_children():
		if child is ConfigButton:
			menus["Accessibility"].buttons.append(child)
			child.size.x = 300
		menus["Accessibility"].objects.append(child)

	$Pages/Accessibility/ButtonSave.connect("pressed", func():
		save_settings()
		open_screen("Main")
	)

	# CONTROLS

	menus["Controls"] = MenuData.new($Pages/Controls, [], [])
	for child in $Pages/Controls.get_children():
		if child is ConfigButton:
			menus["Controls"].buttons.append(child)
			child.size.x = 300
		menus["Controls"].objects.append(child)

	$Pages/Controls/ButtonSave.connect("pressed", func():
		save_settings()
		open_screen("Settings")
	)

func save_settings() -> void:
	GameManager.save_settings()
