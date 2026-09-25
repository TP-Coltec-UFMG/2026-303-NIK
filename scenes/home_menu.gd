# Código do menu inicial

extends CanvasLayer

# Amplitude da animação de levitação do texto
const TEXT_ANIMATION_AMPLITUDE : float = 3.0
# Velocidade da animação de levitação do texto
const TEXT_ANIMATION_SPEED : float = 1.667

# Amplitude da animação do fundo
const BACKGROUND_ANIMATION_AMPLITUDE : float = 0.1

# Velocidade das pessoas no fundo
const PEOPLE_SPEED : float = 30.0

@onready var title : Label = $Title
@onready var start_text : HBoxContainer = $StartText
@onready var background : TextureRect = $Background

# Se o jogador está atualmente no menu. Serve para desativar/ativar
# o tratamento de entrada (no caso, para certificar que o usuário não
# vai interagir com algo atoa) e para parar de calcular as animações
var on_menu : bool = true

func _ready() -> void:
	pass

# Contador para as animações
var _animation_i : float = 0
func _process(delta: float) -> void:
	# Se não estiver no menu, não anima
	if not on_menu: return

	# Preferi colocar só a rotação do título para ser alterada
	#title.offset_transform_position.x = sin(_animation_i - 0.1) * TEXT_ANIMATION_AMPLITUDE
	#title.offset_transform_position.x = cos(_animation_i - 0.1) * TEXT_ANIMATION_AMPLITUDE
	title.offset_transform_rotation = sin(_animation_i - 0.1) * 0.01

	# Movimenta verticalmente o texto de forma suave
	start_text.offset_transform_position.y = sin(_animation_i) * TEXT_ANIMATION_AMPLITUDE
	start_text.offset_transform_rotation = cos(_animation_i) * 0.01

	# Movimenta o fundo em todas as direções de forma suave
	background.offset_transform_position.y = sin(_animation_i + 0.267) * BACKGROUND_ANIMATION_AMPLITUDE
	background.offset_transform_position.x = cos(_animation_i + 0.467) * BACKGROUND_ANIMATION_AMPLITUDE	
	
	_animation_i += delta * TEXT_ANIMATION_SPEED

	animate_person($Background/Nik, delta)

	# Para dar movimento
	$Background/Nik.position.x += PEOPLE_SPEED * delta
	_is_moving[$Background/Nik] = true


func _input(event: InputEvent) -> void:
	# Nota: "event is InputEventMouseButton" detecta quase QUALQUER 
	# 		entrada de mouse (incluindo scroll), mas não movimento.
	if event.is_action_pressed('interact') or event is InputEventMouseButton:
		start_game()

# Abre o menu e ativa suas funções necessárias
func open_menu():
	on_menu = true
	self.visible = true

func start_game() -> void:
	self.visible = false
	on_menu = false
	GameManager.load_map()

# Dicionários que guardam informações da animação
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
	person.scale.y = 0.14 - (sin(_animation_progress[person] * 2) * .01) * _walking_animation_weight[person] + -((0.14 + sin(_animation_progress[person] * .5)) * .01)
	person.position.y = 0 + (-(0.14 + sin(_animation_progress[person] * 2 - PI / 2)) * 20.25) * _walking_animation_weight[person]

	person.reset_physics_interpolation()
