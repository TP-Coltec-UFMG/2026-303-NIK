extends CharacterBody2D


@export var velocidade = 30.0

var flip : float

var progresso_animacao : float = 0
var peso_animacao_andar : float = 0

@onready var sprite : Sprite2D = $Sprite;

var andando : bool

var mover_input : Vector2

var interagir_objeto : Interagivel = null

func _physics_process(delta: float) -> void:
	var raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	mover_input = mover_input.lerp(raw_input, delta / 0.1)

	andando = raw_input.length() > 0

	if raw_input.x != 0:
		flip = 1 if raw_input.x > 0 else -1



	velocity.x = mover_input.x * velocidade
	velocity.y = mover_input.y * velocidade


	move_and_slide()

func _process(delta: float) -> void:		
	animar(delta)

func animar(delta : float):
	peso_animacao_andar = lerpf(peso_animacao_andar, 1 if andando else 0, delta / .075)

	sprite.scale.x = 1 * flip;

	progresso_animacao += velocidade * delta * .035
	
	sprite.rotation = (sin(progresso_animacao) * 0.05) * peso_animacao_andar + (sin(progresso_animacao / 4) * 0.01)
	sprite.scale.y = 1 - (sin(progresso_animacao * 2) * .01) * peso_animacao_andar + -((1 + sin(progresso_animacao * .5)) * .01)
	sprite.position.y = 0 + (-(1 + sin(progresso_animacao * 2 - PI / 2)) * 2.25) * peso_animacao_andar

	sprite.reset_physics_interpolation()