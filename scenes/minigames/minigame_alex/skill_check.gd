# Código responsável pela parte do Skill Check do minigame
extends Node2D

# Tempo mínimo/máximo entre skill checks (em segundos)
# NOTA: se já houver uma skill check rolando, o código vai esperar
#	    a atual acabar para, em seguida, lançar a próxima
const MIN_TIME_BETWEEN_CHECKS : float = 2
const MAX_TIME_BETWEEN_CHECKS : float = 4

# Tamanho mínimo e máximo da área de acerto (em pixels)
const MIN_AREA_SIZE : float = 80
const MAX_AREA_SIZE : float = 490 # um pouquinho menor que a barra toda
const MAX_STARTER_SIZE : float = MAX_AREA_SIZE / 4 # maior tamanho q a área pode começar com

# Velocidade do ponteiro (em pixels/segundo)
const POINTER_SPEED : float = 240

# Tempo mínimo entre tentativas (em segundos)
const SKILL_CHECK_TRY_COOLDOWN : float = 0.7

# Canvas Layer com a interface do skill check
@onready var canvas_layer : CanvasLayer = $CanvasLayer
# Ponto de Controle (pai de toda a interface)
@onready var control : Control = $CanvasLayer/Control
# Barra (em que ficarão a área de acerto e o ponteiro)
@onready var bar : TextureRect = $CanvasLayer/Control/Bar
# Área de acerto
@onready var area_rect: ColorRect = $CanvasLayer/Control/Bar/Area
# Ponteiro
@onready var pointer_rect: ColorRect = $CanvasLayer/Control/Bar/Pointer

# Ponto horizontal mínimo e máximo da barra (retirando a borda)
@onready var bar_min_x : float = 10 - 1
@onready var bar_max_x : float = $CanvasLayer/Control/Bar.size.x - 10 + 1

# Tempo até a próxima skill check
var next_check_time : float = 99

# Se há uma skill check atualmente
var skill_check_enabled : bool = false

# Se a entrada está em cooldown ()
var input_on_cooldown : bool = true

# Informações da área da skill check atual
var curr_area_start : float = -1 # ponto de início da área
var curr_area_end : float = -1 # ponto de fim da área

# A direção do ponteiro (1 = direita; -1 = esquerda)
var pointer_dir : int = 1

func _ready() -> void:
	canvas_layer.visible = false
	input_on_cooldown = false
	next_check_time = randf_range(MIN_TIME_BETWEEN_CHECKS, MAX_TIME_BETWEEN_CHECKS)

func _process(delta: float) -> void:
	if not skill_check_enabled:
		next_check_time -= delta

	# Se chegou o momento de criar uma skill check,
	# obtém um novo tempo e gera a skill check
	if next_check_time < 0:
		next_check_time = randf_range(MIN_TIME_BETWEEN_CHECKS, MAX_TIME_BETWEEN_CHECKS)

		skill_check()
		return
	
	# Se não houver uma skill check atualmente, retorna
	if not skill_check_enabled: return

	# Se chegou até aqui, não criou uma nova skill check 
	# e há uma skill check atualmente. Então, atualiza-a
	tick_skill_check(delta)

func _input(event: InputEvent) -> void:
	if input_on_cooldown: return

	if event.is_action_pressed('interact'):
		check_pointer_on_area()

# Função que faz uma skill check aparecer
func skill_check() -> void:
	skill_check_enabled = true

	# Coloca o ponteiro em uma posição aleatória com uma direção aleatória
	var pointer_pos: Vector2 = get_random_position_on_bar()
	pointer_rect.position = pointer_pos
	pointer_dir = -1 if randi() % 2 else 1

	# Obtém a largura da área
	var width : float = randf_range(MIN_AREA_SIZE, MAX_STARTER_SIZE)

	# Obtém a posição da origem da área
	var p1 : Vector2 = get_random_position_on_bar(0, width)
	curr_area_start = p1.x
	curr_area_end = p1.x + width
	
	# Coloca a área com as bordas em p1 e p2
	area_rect.position = p1
	area_rect.size = Vector2(width, area_rect.size.y) # obs: mantém a posição y
	
	# Faz os trem aparecer
	canvas_layer.visible = true

# Atualiza a skill check atual
func tick_skill_check(delta: float) -> void:
	# Movimenta o ponteiro
	var dx : float = delta * POINTER_SPEED * pointer_dir # Obtém a distância movimentada pelo ponteiro
	pointer_rect.position.x = clampf(pointer_rect.position.x + dx, bar_min_x, bar_max_x)
	if pointer_rect.position.x == bar_max_x:
		pointer_dir = -1
	elif pointer_rect.position.x == bar_min_x:
		pointer_dir = 1

# Verifica se o ponteiro está dentro da área
func check_pointer_on_area() -> void:
	var pos_x : float = pointer_rect.position.x

	# Verifica se o ponteiro está na área (considerando toda a largura do ponteiro)
	# NOTA: poderia ter usado clampf() tbm pra verificar (se o resultado 
	# 		do clampf(pos_x, curr_area_start - pointer_rect.size.x, curr_area_end + pointer_rect.size.x) == pos_x), mas 
	# 		assim é mais bonitinho. (tava pensando sobre minha hootie fruit favorita e veio essa forma de verificar)
	if (curr_area_start - pointer_rect.size.x) <= pos_x and pos_x <= (curr_area_end + pointer_rect.size.x):
		end_skill_check()
	else:
		fail_skill_check()

# Função chamada quando o jogador acerta o skill check
func end_skill_check() -> void:
	skill_check_enabled = false
	input_on_cooldown = false
	canvas_layer.visible = false

# Função chamada quando o jogador erra o skill check
func fail_skill_check() -> void:
	input_on_cooldown = true

	const shake_time : float = SKILL_CHECK_TRY_COOLDOWN * 0.4
	const shake_step : float = shake_time / 5.0

	# Animação quando erra:
	# - Aumenta a área;
	# - Tremida + mudança de cor.
	var tween : Tween = create_tween()

	# Aumenta a área (para facilitar pro jogador)
	increment_area_size(tween)

	# Faz uma tremida curta e uma mudança de cor para mostrar que errou.
	tween\
		.tween_property(bar, 'modulate', Color("#ffb7b5"), shake_step)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_OUT)

	var dir1 : int = -1 if randi() % 2 else 1
	var dir2 : int = -1 if randi() % 2 else 1
	
	tween.parallel().tween_property(control, 'offset_transform_position', Vector2(-8 * dir1, 3 * dir2), shake_step)
	tween.tween_property(control, 'offset_transform_position', Vector2(8 * dir1, -3 * dir2), shake_step)

	tween.tween_property(control, 'offset_transform_position', Vector2(-5 * dir2, 4 * dir1), shake_step)
	tween.tween_property(control, 'offset_transform_position', Vector2(5 * dir2, -4 * dir1), shake_step)

	tween.tween_property(control, 'offset_transform_position', Vector2(0, 0), shake_step)
	tween.parallel().tween_property(bar, 'modulate', Color.WHITE, shake_step)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN)

	await tween.finished

	input_on_cooldown = false

# Aumenta a área, tentando incrementar igualmente em cada lado (partindo o tamanho). 
# Se não conseguir aumentar em um dos dois lados, passa o que não conseguiu pro outro.
# Faz isso com animação ou não (se o tween for oferecido)
func increment_area_size(tween : Tween = null) -> void:
	var curr_size : float = curr_area_end - curr_area_start

	var max_size : float = minf(MAX_AREA_SIZE, bar_max_x - bar_min_x)

	# Tamanho que vai aumentar
	var dsize : float = randf_range(curr_size / 2.67, curr_size / 3.67)
	var new_size : float = minf(curr_size + dsize, max_size)

	# O quanto vai aumentar
	var size_increase : float = new_size - curr_size

	# Aumenta para os dois lados, mantendo o centro sempre que houver espaço
	var new_start : float = clampf(
		curr_area_start - size_increase/2,
		bar_min_x,
		bar_max_x - new_size
	)
	var new_end : float = new_start + new_size

	curr_area_start = new_start
	curr_area_end = new_end

	if tween:
		tween.parallel().tween_property(area_rect, "position:x", new_start, 0.2)
		tween.parallel().tween_property(area_rect, "size:x", new_size, 0.2)
	else:
		area_rect.position.x = new_start
		area_rect.size.x = new_size


# Retorna uma posição aleatória na barra, de forma que ela 
# esteja verticalmente centralizada.
# Caso deseje alterar o intervalo, altere `offset`.
func get_random_position_on_bar(min_offset: float = 0, max_offset: float = 0) -> Vector2:
	return Vector2(
		randf_range(bar_min_x + min_offset, bar_max_x - max_offset),
		9 # centralizado
	)
