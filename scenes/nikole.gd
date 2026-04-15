class_name Nikole extends CharacterBody3D


@export var velocidade = 30.0

@onready var sprites : Node3D = $Sprites
@onready var mao_direita : Node3D = $Sprites/MaoDireita
@onready var mao_direita_base_posicao : Vector3 = $Sprites/MaoDireita.position
@onready var mao_esquerda : Node3D = $Sprites/MaoEsquerda
@onready var mao_esquerda_base_posicao : Vector3 = $Sprites/MaoEsquerda.position
@onready var cabelo : Node3D = $Sprites/Cabeca/Cabelo
@onready var cabelo_base_posicao : Vector3 = $Sprites/Cabeca/Cabelo.position
@onready var sprites_scale : float = $Sprites.scale.x
var sprite_direction = 1
var flip : float

var progresso_animacao : float = 0
var peso_animacao_andar : float = 0
var andando : bool

var mover_input : Vector2

func _physics_process(delta: float) -> void:
	var raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	mover_input = mover_input.lerp(raw_input, delta / 0.2)

	andando = raw_input.length() > 0

	if raw_input.x != 0:
		sprite_direction = 1 if raw_input.x > 0 else -1

	velocity.x = mover_input.x * velocidade
	velocity.z = mover_input.y * velocidade

	move_and_slide()

func _process(delta: float) -> void:
	# animations
	peso_animacao_andar = lerpf(peso_animacao_andar, 1 if andando else 0, delta / .075)

	# sprites.scale.x = lerpf(sprites.scale.x, sprites_scale * -sprite_direction, delta / 0.05)
	# flip = lerpf(flip, PI / 2 * -sprite_direction, delta / 0.1)
	# flip = PI / 2 * -sprite_direction
	sprites.scale.x = sprite_direction;

	progresso_animacao += velocidade * delta * .275
	
	sprites.rotation.z = (sin(progresso_animacao) * 0.05) * peso_animacao_andar + (sin(progresso_animacao / 4) * 0.01)
	sprites.scale.y = 1 - (sin(progresso_animacao * 2) * .01) * peso_animacao_andar + -((1 + sin(progresso_animacao * .5)) * .01)
	sprites.position.y = 1 + ((1 + sin(progresso_animacao * 2 - PI / 2)) * .25) * peso_animacao_andar
	mao_esquerda.position.x = mao_esquerda_base_posicao.x - (sin(progresso_animacao - PI / 2) * .6) * peso_animacao_andar
	mao_esquerda.position.y = mao_esquerda_base_posicao.y + (sin(2 * progresso_animacao + PI / 2) * .125) * peso_animacao_andar
	mao_direita.position.x = mao_direita_base_posicao.x + (sin(progresso_animacao - PI / 2) * .6) * peso_animacao_andar
	mao_direita.position.y = mao_direita_base_posicao.y + (sin(2 * progresso_animacao + PI / 2) * .125) * peso_animacao_andar
	cabelo.rotation.z = (sin(progresso_animacao) * 0.05) * peso_animacao_andar

	sprites.reset_physics_interpolation()

func _on_door_body_entered(body: Node3D, source: Area3D) -> void:
	if source is Porta and body is Nikole:
		print_debug("entrar na casa de " + source.dono + "?")
