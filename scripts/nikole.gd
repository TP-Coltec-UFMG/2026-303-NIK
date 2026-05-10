class_name Nikole extends CharacterBody3D


@export var velocidade = 30.0
@export var menu : Menu

@onready var camera : Camera3D = $Camera3D if has_node("Camera3D") else null
@onready var camera_pivot : Node3D = $CameraPivot if has_node("CameraPivot") else null
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

var interagir_objeto : Node = null

const coeficiente_rotacao_camera : float = 0.03

func _physics_process(delta: float) -> void:
	var raw_input = Input.get_vector("move_left", "move_right", "move_up", "move_down")

	if camera_pivot:
		if Input.is_action_pressed("girar_tela_direita"):
			camera_pivot.rotation.y -= coeficiente_rotacao_camera
			sprites.rotation.y -= coeficiente_rotacao_camera
		if Input.is_action_pressed("girar_tela_esquerda"):
			camera_pivot.rotation.y += coeficiente_rotacao_camera
			sprites.rotation.y += coeficiente_rotacao_camera
		raw_input = raw_input.rotated(-camera_pivot.rotation.y)

	mover_input = mover_input.lerp(raw_input, delta / 0.2)

	andando = raw_input.length() > 0

	if raw_input.x != 0:
		sprite_direction = 1 if raw_input.x > 0 else -1



	velocity.x = mover_input.x * velocidade
	velocity.z = mover_input.y * velocidade


	move_and_slide()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interagir"):
		if interagir_objeto != null:
			interagir_objeto.interagir()
		else: print_debug("não tem nada pra interagir...")

	if Input.is_action_just_pressed("pausar"):
		menu.abrir_tela("Menu")
		get_tree().paused = true
		
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

func _on_porta_body_entered(body: Node3D, source: Area3D) -> void:
	if source is Interagivel and body == self:
		interagir_objeto = source
		print_debug("interagir com ", interagir_objeto.name, " disponivel")


func _on_porta_body_exited(body: Node3D, source: Area3D) -> void:
	if source == interagir_objeto and body == self:
		print_debug("interagir com ", interagir_objeto.name, " indisponivel")
		interagir_objeto = null
