# Código do menu inicial

extends CanvasLayer

# Amplitude da animação de levitação do texto
const TEXT_ANIMATION_AMPLITUDE : float = 3.0
# Velocidade da animação de levitação do texto
const TEXT_ANIMATION_SPEED : float = 1.667

# Amplitude da animação do fundo
const BACKGROUND_ANIMATION_AMPLITUDE : float = 1.3

@onready var title : Label = $Title
@onready var start_text : Label = $StartText
@onready var background : TextureRect = $Background

# Se o jogador está atualmente no menu. Serve para desativar/ativar
# o tratamento de entrada (no caso, para certificar que o usuário não
# vai interagir com algo atoa) e para parar de calcular as animações
var on_menu : bool = true

func _ready() -> void:
	pass

# Contador para as animações
var _animation_i : float = 0
func _process(_delta: float) -> void:
	# Se não estiver no menu, não anima
	if not on_menu: return

	# Preferi colocar só a rotação do título para ser alterada
	#title.offset_transform_position.x = sin(_animation_i - 0.1) * TEXT_ANIMATION_AMPLITUDE
	#title.offset_transform_position.x = cos(_animation_i - 0.1) * TEXT_ANIMATION_AMPLITUDE
	title.offset_transform_rotation = sin(_animation_i - 0.1) * 0.01

	# Movimenta verticalmente o texto de forma suave
	start_text.offset_transform_position.y = sin(_animation_i) * TEXT_ANIMATION_AMPLITUDE
	start_text.offset_transform_rotation = cos(_animation_i) * 0.01

	background.offset_transform_position.y = sin(_animation_i + 0.267) * BACKGROUND_ANIMATION_AMPLITUDE
	background.offset_transform_position.x = cos(_animation_i + 0.467) * BACKGROUND_ANIMATION_AMPLITUDE	
	
	_animation_i += _delta * TEXT_ANIMATION_SPEED


func _input(event: InputEvent) -> void:
	if event.is_action_pressed('interact'):
		start_game()

func start_game() -> void:
	self.visible = false
	on_menu = false
	GameManager.load_map()
