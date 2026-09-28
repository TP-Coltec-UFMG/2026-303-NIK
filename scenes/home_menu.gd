# Código do menu inicial

extends CanvasLayer

# Amplitude da animação de levitação do texto
const TEXT_ANIMATION_AMPLITUDE : float = 3.0
# Velocidade da animação de levitação do texto
const TEXT_ANIMATION_SPEED : float = 1.667

# Amplitude da animação do fundo
const BACKGROUND_ANIMATION_AMPLITUDE : float = 1
# Velocidade da animação do fundo
const BACKGROUND_ANIMATION_SPEED : float = 1.1

# Velocidade das pessoas no fundo
const PEOPLE_SPEED : float = 30.0

# Tempo para trocar de botão (em segundos)
const POINTER_SPEED : float = .15

# Posição horizontal normal dos botões
const BUTTON_STANDARD_OFFSET_X : float = 40
# Posição horizontal fora da tela dos botões
const BUTTON_OFF_SCREEN_OFFSET_X : float = -320



# Classe que representa um botão da tela
class HomeMenuButton:
	# Velocidade para resetar o Offset Transform
	const _OFFSET_TRANSFORM_RESET_SPEED : float = 0.25

	# Constantes do Offset Transform do Label
	const _STANDARD_OFFSET_TRANSFORM_POSITION : Vector2 = Vector2(0, 0)
	const _STANDARD_OFFSET_TRANSFORM_ROTATION : float = 0

	var action : String # a ação do botão (continuar o jogo, opções etc)
	var label : Label
	var button : Button # botão no GUI

	var _current_tween : Tween

	func _init(label_node : Label) -> void:
		action = label_node.name
		label = label_node
		button = label_node.get_node("Button")

	# Reinicia o offset visual do botão, de forma suave (smooth = true)
	# ou não (smooth = false)
	func reset_offset_transform(smooth = true) -> void:
		if not smooth:
			label.offset_transform_position = Vector2(0, 0)
			label.offset_transform_rotation = 0
		else:
			_current_tween = label.create_tween()
			_current_tween.tween_property(
				label, 
				'offset_transform_position', 
				_STANDARD_OFFSET_TRANSFORM_POSITION, 
				_OFFSET_TRANSFORM_RESET_SPEED
			).set_trans(Tween.TRANS_SPRING)
			_current_tween.tween_property(
				label, 
				'offset_transform_rotation', 
				_STANDARD_OFFSET_TRANSFORM_ROTATION, 
				_OFFSET_TRANSFORM_RESET_SPEED
			).set_trans(Tween.TRANS_SPRING)

	# Retorna a posição y global do botão
	func get_global_y() -> float:
		return label.global_position.y

@onready var background : TextureRect = $Background
@onready var title : Label = $Title
@onready var buttons_node : VBoxContainer = $Buttons
@onready var pointer : Label = $Pointer
@onready var tips : VBoxContainer = $Tips

# Se o jogador está atualmente no menu. Serve para desativar/ativar
# o tratamento de entrada (no caso, para certificar que o usuário não
# vai interagir com algo atoa) e para parar de calcular as animações
var on_menu : bool = true
# Se os botões estiverem ligados
var buttons_enabled : bool = true

# Lista com os botões da tela
var buttons : Array[HomeMenuButton] = []
# Índice no vetor de botões do botão atualmente selecionado
var current_selected_button_index : int = 0

# Tween do ponteiro (quando ele troca de posição)
var _pointer_tween : Tween

func _ready() -> void:
	# Cria as representações dos botões
	update_menu_buttons()
	# Deixa todos os npcs invisíveis
	update_menu_characters()

# Contadores para as animações
var _animation_i : float = 0
var _background_animation_i : float = 0
func _process(delta: float) -> void:
	# Se não estiver no menu, não anima
	if not on_menu: return

	# Atualiza as dicas de controle
	update_controls_tip()
	# Atualiza os persoagens
	set_menu_characters_enabled()

	#start_key.text = "[font_size=26]" + OS.get_keycode_string(GameManager.get_setting("interact"))

	# Preferi colocar só a rotação do título para ser alterada
	#title.offset_transform_position.x = sin(_animation_i - 0.1) * TEXT_ANIMATION_AMPLITUDE
	#title.offset_transform_position.x = cos(_animation_i - 0.1) * TEXT_ANIMATION_AMPLITUDE
	title.offset_transform_rotation = sin(_animation_i - 0.1) * 0.01

	# Movimenta verticalmente o texto e o ponteiro de forma suave
	var off_y : float = sin(_animation_i) * TEXT_ANIMATION_AMPLITUDE
	var off_rot : float = cos(_animation_i) * 0.005
	get_current_selected_button().label.offset_transform_position.y = off_y
	get_current_selected_button().label.offset_transform_rotation = off_rot
	pointer.offset_transform_position.y = off_y
	pointer.offset_transform_rotation = off_rot

	# Movimenta o fundo em todas as direções de forma suave
	var a : float = sin(_background_animation_i + 0.267)
	var b : float = cos(_background_animation_i + 0.467)
	background.offset_transform_position.y = sin(a * BACKGROUND_ANIMATION_SPEED + b * 0.4) * BACKGROUND_ANIMATION_AMPLITUDE
	background.offset_transform_position.x = cos(b * BACKGROUND_ANIMATION_SPEED - a) * BACKGROUND_ANIMATION_AMPLITUDE	
	
	_animation_i += delta * TEXT_ANIMATION_SPEED
	_background_animation_i += delta * BACKGROUND_ANIMATION_SPEED

	animate_person($Background/Nik, delta)

	# Para dar movimento (o movimento não tá funfando ainda)
	#$Background/Nik.position.x += PEOPLE_SPEED * delta
	#_is_moving[$Background/Nik] = true

func _input(event: InputEvent) -> void:
	if not buttons_enabled: return
	var movement : int = int(event.is_action_pressed('move_down')) - int(event.is_action_pressed('move_up'))
	if movement:
		move_pointer(movement)
	elif event.is_action_pressed('interact'):
		press_current_button()

# Retorna o botão atualmente selecionado
func get_current_selected_button() -> HomeMenuButton:
	return buttons[current_selected_button_index]

# Move o ponteiro da opção para cima (dir = -1) ou para baixo (dir = 1)
func move_pointer(dir : int) -> void:
	# Reinicia a posição da opção atualmente selecionada
	get_current_selected_button().reset_offset_transform()

	# Deixa o índice dentro do intervalo dos botões (inclusive ao voltar de zero)
	current_selected_button_index = posmod(current_selected_button_index + dir, buttons.size())

	# Se houver, interrompe o tween anterior
	if _pointer_tween and _pointer_tween.is_valid(): _pointer_tween.kill()

	_pointer_tween = pointer.create_tween()
	_pointer_tween.tween_property(pointer, 'position:y', get_current_selected_button().get_global_y(), POINTER_SPEED)
	
	# Reinicia a animação
	_animation_i = 0

func reset_pointer(reset = true) -> void:
	if buttons.is_empty():
		return

	if reset: 
		current_selected_button_index = 0
	else:
		# Certifica que o índice está dentro do intervalo das configurações
		current_selected_button_index = min(current_selected_button_index, buttons.size() - 1)

	# Reposiciona
	pointer.position.y = get_current_selected_button().get_global_y()
	
# Aperta o botão atualmente selecionado pelo current_selected_button_index
func press_current_button():
	match get_current_selected_button().action:
		"ContinueGame": _on_continue_game_pressed()
		"NewGame": _on_new_game_pressed()
		"Options": _on_options_pressed()
		"Exit": _on_exit_pressed()

# Atualiza o texto das dicas de controle
func update_controls_tip() -> void:
	var move : HBoxContainer = tips.get_node("Move")
	var interact : HBoxContainer = tips.get_node("Interact")
	# Atualiza o texto
	move.get_node("up").get_node("Botao").text = OS.get_keycode_string(GameManager.get_setting("move_up"))
	move.get_node("down").get_node("Botao").text = OS.get_keycode_string(GameManager.get_setting("move_down"))
	interact.get_node("interact").get_node("Botao").text = OS.get_keycode_string(GameManager.get_setting("interact"))

# Abre o menu e ativa suas funções necessárias
func open_menu():
	update_menu_buttons()
	set_menu_labels_enabled(true)
	set_menu_characters_enabled()
	on_menu = true
	self.visible = true

# Fecha o menu e desativa suas funções
func close_menu():
	self.visible = false
	on_menu = false

# Atualiza os botões do menu
func update_menu_buttons() -> void:
	buttons.clear()

	for btn in buttons_node.get_children():
		btn.visible = true

		# Se não tiver save, não mostra o botão de continuar o jogo
		if btn.name == "ContinueGame" and not GameManager.has_save():
			btn.visible = false
			continue # não adiciona no vetor
		buttons.append( HomeMenuButton.new(btn) )
	
	# Chama o reset_pointer só quando o VBoxContainer já tiver
	# sido recalculado
	call_deferred("reset_pointer", false)

# Deixa todos os npcs invisíveis
func update_menu_characters() -> void:
	for character in background.get_children():
		character.visible = false

# Dicionários que guardam informações das animações
var _previous_x : Dictionary = {}
var _walking_animation_weight : Dictionary = {}
var _animation_progress : Dictionary = {}
var _is_moving : Dictionary = {}
# Anima o sprite de pessoa dado
func animate_person(person : TextureRect, delta : float):
	# Inicializa, se não houver, os dicionários
	if not _previous_x.has(person):
		_previous_x[person] = person.global_position.x
	if not _walking_animation_weight.has(person):
		_walking_animation_weight[person] = 0
	if not _animation_progress.has(person):
		_animation_progress[person] = 0
	if not _is_moving.has(person):
		_is_moving[person] = false

	person.scale.x = -1.0 if (person.global_position.x < _previous_x[person]) else 1.0 if (person.global_position.x > _previous_x[person]) else person.scale.x
	_previous_x[person] = person.global_position.x

	_walking_animation_weight[person] = lerpf(_walking_animation_weight[person], 1 if _is_moving[person] else 0, delta / .075)

	_animation_progress[person] += PEOPLE_SPEED * delta * .035
	
	person.rotation = (sin(_animation_progress[person]) * 0.1) * _walking_animation_weight[person] + (sin(_animation_progress[person] / 4) * 0.01)
	#person.scale.y = 0.14 - (sin(_animation_progress[person] * 2) * .01) * _walking_animation_weight[person] + -((0.14 + sin(_animation_progress[person] * .5)) * .01)
	#person.position.y = 0 + (-(0.14 + sin(_animation_progress[person] * 2 - PI / 2)) * 20.25) * _walking_animation_weight[person]

	person.reset_physics_interpolation()

# Determina se os botões estão visíveis e funcionais
func set_menu_labels_enabled(buttons_visibility : bool):
	title.visible = buttons_visibility
	buttons_node.visible = buttons_visibility
	pointer.visible = buttons_visibility
	buttons_enabled = buttons_visibility

func set_menu_characters_enabled() -> void:
	if GameManager.has_save():
		background.get_node("Nik").visible = true
		background.get_node("VovoMaria").visible = true
	if GameManager.get_game_data("caio_minigame_completed"):
		background.get_node("Caio").visible = true
	if GameManager.get_game_data("joao_minigame_completed"):
		background.get_node("Joao").visible = true
	if GameManager.get_game_data("alex_minigame_completed"):
		background.get_node("Alex").visible = true
	if GameManager.get_game_data("luzia_minigame_completed"):
		background.get_node("DonaLuzia").visible = true
		background.get_node("Luis").visible = true
		background.get_node("Flavia").visible = true
		background.get_node("Francisco").visible = true
	if GameManager.get_game_data("leonardo_minigame_completed"):
		background.get_node("Leonardo").visible = true

## Evento dos botões quando clicados ##

func _on_continue_game_pressed() -> void:
	close_menu()
	GameManager.load_save_and_start()

func _on_new_game_pressed() -> void:
	close_menu()
	GameManager.create_new_game()
	
func _on_options_pressed() -> void:
	#close_menu()
	set_menu_labels_enabled(false)
	GameManager.menu.open_screen("Main", true)

func _on_exit_pressed() -> void:
	get_tree().quit()
