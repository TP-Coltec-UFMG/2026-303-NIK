# Código responsável pela parte do Skill Check do minigame
extends Node2D

# Tempo mínimo/máximo entre skill checks (em segundos)
# NOTA: se já houver uma skill check rolando, o código vai esperar
#	    a atual acabar para, em seguida, lançar a próxima
const MIN_TIME_BETWEEN_CHECKS : float = 4
const MAX_TIME_BETWEEN_CHECKS : float = 7

# Tamanho mínimo e máximo da área de acerto (em pixels)
const MIN_AREA_SIZE : float = 80
const MAX_AREA_SIZE : float = 500 # um pouquinho menor que a barra toda
const MAX_STARTER_SIZE : float = MAX_AREA_SIZE / 4 # maior tamanho q a área pode começar com

# Tempo mínimo entre tentativas (em segundos)
const SKILL_CHECK_TRY_COOLDOWN : float = 0.7

# Velocidade inicial do ponteiro (em pixels/segundo)
const INITIAL_POINTER_SPEED : float = 240

# Configurações do gradiente da tela amaldiçoada
const CURSE_GRADIENT_POINT : int = 1
const CURSE_GRADIENT_START : float = 0.9 #0.32743362
const CURSE_GRADIENT_END : float = 0.3
const CURSE_TWEEN_DURATION : float = 4.0

# Configurações dos bad chars durante a maldição
const BAD_CHAR_INITIAL_AMOUNT : int = 25
const BAD_CHAR_SPAWN_INTERVAL : float = 0.18
const BAD_CHAR_AMOUNT_INCREASE_TIME : float = 30.3
const BAD_CHAR_SPEED_SCALE_INCREASE : float = 0.01
const BAD_CHAR_MAX_SPEED_SCALE : float = 2

# Canvas Layer com a interface do skill check
@onready var canvas_layer : CanvasLayer = $CanvasLayer
# Ponto de Controle (pai de toda a interface)
@onready var control : Control = $CanvasLayer/Control
# Ponto de Controle da tela amaldiçoada
@onready var wicked_control : Control = $CanvasLayer/Cursed
# Barra (em que ficarão a área de acerto e o ponteiro)
@onready var bar : TextureRect = $CanvasLayer/Control/Bar
# Área de acerto
@onready var area_rect: ColorRect = $CanvasLayer/Control/Bar/Area
@onready var area_rect_l: TextureRect = $CanvasLayer/Control/Bar/AreaLeft
@onready var area_rect_r: TextureRect = $CanvasLayer/Control/Bar/AreaRight
# Ponteiro
@onready var pointer_rect: TextureRect = $CanvasLayer/Control/Bar/Pointer
# Gradiente da tela amaldiçoada
@onready var gradient: TextureRect = $CanvasLayer/Cursed/Gradient
@onready var gradient_texture: GradientTexture2D = gradient.texture as GradientTexture2D
# Lugar onde os caracteres serão criados
@onready var bad_char_particles: GPUParticles2D = $BadCharsParticles

# Ponto horizontal mínimo e máximo da barra (retirando a borda)
@onready var bar_min_x : float = 10 - 1
@onready var bar_max_x : float = $CanvasLayer/Control/Bar.size.x - 10

var bad_chars : Array[TextureRect] = []

# Velocidade do ponteiro (em pixels/segundo)
var pointer_speed : float = INITIAL_POINTER_SPEED

# Tempo até a próxima skill check
var next_check_time : float = 99

# Se há uma skill check atualmente
var skill_check_enabled : bool = false

# Se a tela está amaldiçoada
var is_screen_cursed : bool = false

# Identificador do ciclo dos caracteres amaldiçoados (pra evitar 
# ter mais de um ciclo na ativa ao mesmo tempo)
var bad_chars_cycle_id : int = 0

# Se a entrada está em cooldown ()
var input_on_cooldown : bool = true

# Informações da área da skill check atual
var curr_area_start : float = -1 # ponto de início da área
var curr_area_end : float = -1 # ponto de fim da área

# A direção do ponteiro (1 = direita; -1 = esquerda)
var pointer_dir : int = 1

# Se o burnout começou
var burnout_started : bool = false
# Se está em burnout (ou seja, não consegue completar o skillcheck)
var is_on_burnout : bool = false
# O tempo que o jogador está em burnout
var time_on_burnout : float = 0

var curse_tween : Tween = null

func _ready() -> void:
	canvas_layer.visible = false
	control.visible = false
	wicked_control.visible = false

	skill_check_enabled = false
	input_on_cooldown = false
	is_on_burnout = false
	burnout_started = false
	time_on_burnout = 0
	pointer_speed = INITIAL_POINTER_SPEED
	next_check_time = randf_range(MIN_TIME_BETWEEN_CHECKS, MAX_TIME_BETWEEN_CHECKS)


func _process(delta: float) -> void:
	# Faz nada se o minigame estiver parado
	if not $"../TaskGenerator".is_minigame_running: 
		return

	if is_on_burnout and not burnout_started:
		burnout_started = true
		curse_screen()
		skill_check(true)
		return
	elif not is_on_burnout:
		if not skill_check_enabled:
			next_check_time -= delta

		# Se chegou o momento de criar uma skill check,
		# obtém um novo tempo e gera a skill check
		if next_check_time < 0:
			next_check_time = randf_range(MIN_TIME_BETWEEN_CHECKS, MAX_TIME_BETWEEN_CHECKS)
			curse_screen()
			await get_tree().create_timer(1.3).timeout # tempo até aparecer o skill check
			skill_check()
			return
	
	# Se não houver uma skill check atualmente, retorna
	if not skill_check_enabled: return

	# Se estiver no burnout, dá umas enlouquecidas:
	if is_on_burnout:
		# Aumenta a velocidade
		pointer_speed += randf_range(10, 30) * delta
		# Se o jogador já está bastante tempo no burnout, enlouquece mais
		if time_on_burnout > 6:
			# O ponteiro troca de sentido aleatoriamente
			if randf() > 0.99:
				pointer_dir = -1 if randi() % 2 else 1

		# Se o jogador está a mais tempo (e se o `time_on_burnout` acabou de trocar de segundo)
		if time_on_burnout > 8 and (time_on_burnout - floor(time_on_burnout)) < 0.01:	
			# A área troca aleatoriamente de posição
			randomize_area_position()

		time_on_burnout += delta

	# Se chegou até aqui, não criou uma nova skill check 
	# e há uma skill check atualmente. Então, atualiza-a
	tick_skill_check(delta)

func _input(event: InputEvent) -> void:
	if input_on_cooldown or not skill_check_enabled: return

	if event.is_action_pressed('interact'):
		check_pointer_on_area()
	else:
		skill_check()

# Função que faz uma skill check aparecer
func skill_check(force : bool = false) -> void:
	if (not force) and skill_check_enabled: return

	skill_check_enabled = true

	# Coloca o ponteiro em uma posição aleatória com uma direção aleatória
	var pointer_pos: Vector2 = get_random_position_on_bar()
	pointer_rect.position = pointer_pos
	pointer_dir = -1 if randi() % 2 else 1

	# Altera a posição da área
	randomize_area_position()
	
	# Faz os trem aparecer
	control.visible = true

# Atualiza a skill check atual
func tick_skill_check(delta: float) -> void:
	if not skill_check_enabled: return

	# Movimenta o ponteiro
	var dx : float = delta * pointer_speed * pointer_dir # Obtém a distância movimentada pelo ponteiro
	pointer_rect.position.x = clampf(pointer_rect.position.x + dx, bar_min_x, bar_max_x)
	if pointer_rect.position.x == bar_max_x:
		pointer_dir = -1
	elif pointer_rect.position.x == bar_min_x:
		pointer_dir = 1

# Verifica se o ponteiro está dentro da área
func check_pointer_on_area() -> void:
	# Verifica se o ponteiro está na área (considerando toda a largura do ponteiro)
	if is_pointer_touching_area():
		if not is_on_burnout:
			end_skill_check()
		else:
			randomize_area_position()
	else:
		fail_skill_check()

# Verifica se o ponteiro está tocando a área
func is_pointer_touching_area() -> bool:
	var pos_x : float = pointer_rect.position.x
	# Verifica se o ponteiro está na área (considerando toda a largura do ponteiro)
	# NOTA: poderia ter usado clampf() tbm pra verificar (se o resultado 
	# 		do clampf(pos_x, curr_area_start - pointer_rect.size.x, curr_area_end) == pos_x), mas 
	# 		assim é mais bonitinho. (tava pensando sobre minha hootie fruit favorita e veio essa forma de verificar)
	return (curr_area_start - pointer_rect.size.x) <= pos_x and pos_x <= (curr_area_end);

# Função chamada quando o jogador acerta o skill check
func end_skill_check() -> void:
	skill_check_enabled = false
	input_on_cooldown = false
	control.visible = false
	await uncurse_screen()
	wicked_control.visible = false
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

	# Aumenta a área (para facilitar pro jogador)
	# NOTA: se estiver no burnout, não faz isso!
	if not is_on_burnout:
		increment_area_size(tween)

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
		tween.parallel().tween_property(area_rect_l, "position:x", new_start - 12.0, 0.2)
		tween.parallel().tween_property(area_rect_r, "position:x", new_start + new_size - 12, 0.2)
	else:
		area_rect.position.x = new_start
		area_rect_l.position.x = new_start - 12.0
		area_rect_r.position.x = new_start + new_size - 12.0
		area_rect.size.x = new_size

# Coloca a área do skill check em uma posição aleatória.
func randomize_area_position() -> void:
	# Obtém a largura da área
	var width : float = randf_range(MIN_AREA_SIZE, MAX_STARTER_SIZE)

	# Obtém a posição da origem da área
	var p1 : Vector2 = get_random_position_on_bar(12, width - 12)
	curr_area_start = p1.x
	curr_area_end = p1.x + width
	
	# Coloca a área com as bordas em p1 e p2
	area_rect.position = p1
	area_rect.size = Vector2(width, area_rect.size.y) # obs: mantém a posição y

	area_rect_l.position.x = p1.x - 12.0
	area_rect_r.position.x = p1.x + width - 12.0
	area_rect.size.x = width

# Amaldiçoa a tela
func curse_screen() -> void:
	if curse_tween and curse_tween.is_valid():
		curse_tween.kill()

	is_screen_cursed = true
	bad_chars_cycle_id += 1
	if can_have_bad_chars():
		start_bad_chars(bad_chars_cycle_id)

	canvas_layer.visible = true
	wicked_control.visible = true

	# Define os pontos iniciais
	gradient_texture.gradient.set_offset(CURSE_GRADIENT_POINT, CURSE_GRADIENT_START)
	gradient.modulate.a = 0

	curse_tween = create_tween()

	curse_tween.parallel().tween_property(
		gradient, 
		'modulate:a',
		1,
		CURSE_TWEEN_DURATION / 4
	)
	curse_tween.parallel().tween_method(
		Callable(self, "set_curse_gradient_offset"),
		gradient_texture.gradient.get_offset(CURSE_GRADIENT_POINT),
		CURSE_GRADIENT_END,
		CURSE_TWEEN_DURATION
	)

# Define o offset do gradiente
func set_curse_gradient_offset(offset: float) -> void:
	gradient_texture.gradient.set_offset(CURSE_GRADIENT_POINT, offset)

# Retira a tela amaldiçoada
func uncurse_screen() -> void:
	is_screen_cursed = false
	bad_chars_cycle_id += 1

	if curse_tween and curse_tween.is_valid():
		curse_tween.kill()

	# Retira o gradiente de fundo
	curse_tween = create_tween()

	curse_tween.parallel().tween_property(
		gradient, 
		'modulate:a',
		0,
		CURSE_TWEEN_DURATION / 6
	)

	curse_tween.parallel().tween_method(
		Callable(self, "set_curse_gradient_offset"),
		gradient_texture.gradient.get_offset(CURSE_GRADIENT_POINT),
		CURSE_GRADIENT_START,
		CURSE_TWEEN_DURATION / 6
	)

	stop_bad_chars()
	await curse_tween.finished

# Inicia o processo que cria os caracteres da tela amaldiçoada
func start_bad_chars(cycle_id: int) -> void:
	if can_have_bad_chars():
		# não acho que há necessidade de reiniciar
		# bad_char_particles.restart()
		bad_char_particles.emitting = true
		bad_char_particles.speed_scale = 1.05
		
		# não vejo necessidade de deixar visível/invisível
		# bad_char_particles.visible = true

		# também não vejo necessidade de parar o processamento do nó
		# bad_char_particles.process_mode = PROCESS_MODE_DISABLED
		_run_bad_char_handler(cycle_id)
		
		

# Loop que lida com os caracteres amaldiçoados (que, por exemplo,
# aumentam ao longo do tempo)
func _run_bad_char_handler(cycle_id: int) -> void:
	var elapsed_time := 0.0

	while is_screen_cursed and cycle_id == bad_chars_cycle_id and can_have_bad_chars():
		var target_amount := mini(
			BAD_CHAR_INITIAL_AMOUNT + int(elapsed_time / BAD_CHAR_AMOUNT_INCREASE_TIME),
			bad_char_particles.amount
		)

		# Aumenta a quantidade de partícula para o "target amount"
		bad_char_particles.amount_ratio = float(target_amount) / bad_char_particles.amount

		# Aumenta a velocidade da animação das partículas
		bad_char_particles.speed_scale += BAD_CHAR_SPEED_SCALE_INCREASE
		bad_char_particles.speed_scale = min(bad_char_particles.speed_scale, BAD_CHAR_MAX_SPEED_SCALE)

		await get_tree().create_timer(BAD_CHAR_SPAWN_INTERVAL).timeout
		
		elapsed_time += BAD_CHAR_SPAWN_INTERVAL

# Para de gerar os caracteres amaldiçoados
func stop_bad_chars() -> void:
	bad_char_particles.emitting = false
	# obs: para deixar invisível, teria q haver um await aqui (pras
	#	   partículas não sumirem do nada)
	#bad_char_particles.visible = false

# Retorna uma posição aleatória na barra, de forma que ela 
# esteja verticalmente centralizada.
# Caso deseje alterar o intervalo, altere `offset`.
func get_random_position_on_bar(min_offset: float = 12, max_offset: float = -12) -> Vector2:
	return Vector2(
		randf_range(bar_min_x + min_offset, bar_max_x - max_offset),
		0 # centralizado
	)

# Retorna se pode ter caracteres da tela amaldiçoada na tela
func can_have_bad_chars() -> bool:
	return\
		(not GameManager.settings.has("flashing_elements"))\
		or (GameManager.settings.has("flashing_elements") and GameManager.settings['flashing_elements'])
