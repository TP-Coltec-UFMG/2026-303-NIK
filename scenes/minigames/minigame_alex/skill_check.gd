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
const BAD_CHAR_SPAWN_INTERVAL : float = 0.14
const BAD_CHAR_AMOUNT_INCREASE_TIME : float = 0.3
const BAD_CHAR_MAX_AMOUNT : int = 30
const BAD_CHAR_LIFETIME : float = 0.2
const BAD_CHAR_SHAKE_DISTANCE : float = 6.0
const BAD_CHAR_SHAKE_STEP : float = 0.09

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
# Ponteiro
@onready var pointer_rect: ColorRect = $CanvasLayer/Control/Bar/Pointer
# Gradiente da tela amaldiçoada
@onready var gradient: TextureRect = $CanvasLayer/Cursed/Gradient
@onready var gradient_texture: GradientTexture2D = gradient.texture as GradientTexture2D
# Lugar onde os caracteres serão criados
@onready var bad_chars_parent: Control = $CanvasLayer/Cursed/BadChars

# Ponto horizontal mínimo e máximo da barra (retirando a borda)
@onready var bar_min_x : float = 10 - 1
@onready var bar_max_x : float = $CanvasLayer/Control/Bar.size.x - 10

var bad_chars : Array[TextureRect] = []
var active_bad_chars : Array[TextureRect] = []
var bad_chars_cycle_id : int = 0

# Velocidade do ponteiro (em pixels/segundo)
var pointer_speed : float = INITIAL_POINTER_SPEED

# Tempo até a próxima skill check
var next_check_time : float = 99

# Se há uma skill check atualmente
var skill_check_enabled : bool = false

# Se a tela está amaldiçoada
var is_screen_cursed : bool = false

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

	# Coloca os caracteres no vetor
	for c in $BadChars.get_children():
		if c is TextureRect:
			bad_chars.append(c)
			c.visible = false
			c.mouse_filter = Control.MOUSE_FILTER_IGNORE


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
	else:
		area_rect.position.x = new_start
		area_rect.size.x = new_size

# Coloca a área do skill check em uma posição aleatória.
func randomize_area_position() -> void:
	# Obtém a largura da área
	var width : float = randf_range(MIN_AREA_SIZE, MAX_STARTER_SIZE)

	# Obtém a posição da origem da área
	var p1 : Vector2 = get_random_position_on_bar(0, width)
	curr_area_start = p1.x
	curr_area_end = p1.x + width
	
	# Coloca a área com as bordas em p1 e p2
	area_rect.position = p1
	area_rect.size = Vector2(width, area_rect.size.y) # obs: mantém a posição y

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

	await curse_tween.finished
	clear_bad_chars()

# Inicia o processo que cria os caracteres da tela amaldiçoada
func start_bad_chars(cycle_id: int) -> void:
	if can_have_bad_chars():
		spawn_bad_char()
		_run_bad_char_spawner(cycle_id)

# Loop que adiciona mais caracteres ao longo do tempo
func _run_bad_char_spawner(cycle_id: int) -> void:
	var elapsed_time := 0.0

	while is_screen_cursed and cycle_id == bad_chars_cycle_id and can_have_bad_chars():
		var target_amount := mini(
			1 + int(elapsed_time / BAD_CHAR_AMOUNT_INCREASE_TIME),
			BAD_CHAR_MAX_AMOUNT
		)

		while active_bad_chars.size() < target_amount:
			spawn_bad_char()

		await get_tree().create_timer(BAD_CHAR_SPAWN_INTERVAL).timeout
		elapsed_time += BAD_CHAR_SPAWN_INTERVAL

# Cria um caractere na tela
func spawn_bad_char() -> void:
	if not can_have_bad_chars(): return

	if bad_chars.is_empty() or active_bad_chars.size() >= BAD_CHAR_MAX_AMOUNT:
		return

	var template: TextureRect = bad_chars.pick_random()
	var bad_char: TextureRect = template.duplicate()
	bad_chars_parent.add_child(bad_char)
	active_bad_chars.append(bad_char)

	bad_char.rotation = randf_range(-0.2, 0.2)
	bad_char.scale = Vector2(0.4, 0.4)
	bad_char.position = get_random_bad_char_position(bad_char)
	bad_char.modulate = Color(1, 1, 1, 0)
	bad_char.visible = true
	bad_char.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var tween := create_tween()
	tween.tween_property(bad_char, "modulate:a", 1.0, 0.2)
	tween.parallel().tween_property(bad_char, "scale", template.scale, 0.13)
	tween.tween_interval(0.1)
	add_bad_char_shake(tween, bad_char)
	tween.tween_interval(maxf(0.0, BAD_CHAR_LIFETIME - 1.2))
	tween.tween_property(bad_char, "modulate:a", 0.0, 0.3)
	tween.tween_callback(remove_bad_char.bind(bad_char.get_instance_id()))

# Faz o caractere dado se tremer 
func add_bad_char_shake(tween: Tween, bad_char: TextureRect) -> void:
	var original_position := bad_char.position
	var shake_directions := [
		Vector2(-1, -1),
		Vector2(1, 1),
		Vector2(-1, 1),
		Vector2(1, -1),
		Vector2.ZERO
	]

	for direction in shake_directions:
		tween.parallel().tween_property(
			bad_char,
			"position",
			original_position + direction * BAD_CHAR_SHAKE_DISTANCE,
			BAD_CHAR_SHAKE_STEP
		)

# Apaga um caractere (idealmente, seria bom salvar num bucket)
func remove_bad_char(bad_char_id: int) -> void:
	var bad_char := instance_from_id(bad_char_id) as TextureRect
	if not is_instance_valid(bad_char):
		return

	active_bad_chars.erase(bad_char)
	bad_char.queue_free()

# Limpa todos os caracteres da tela
func clear_bad_chars() -> void:
	for bad_char in active_bad_chars:
		if is_instance_valid(bad_char):
			bad_char.queue_free()
	active_bad_chars.clear()

# Obtém uma posição aleatória para posicionar um caractere
func get_random_bad_char_position(bad_char: TextureRect) -> Vector2:
	var screen_size := get_viewport_rect().size
	var char_size := bad_char.size * bad_char.scale

	return Vector2(
		randf_range(0.0, maxf(0.0, screen_size.x - char_size.x)),
		randf_range(0.0, maxf(0.0, screen_size.y - char_size.y))
	)

# Retorna uma posição aleatória na barra, de forma que ela 
# esteja verticalmente centralizada.
# Caso deseje alterar o intervalo, altere `offset`.
func get_random_position_on_bar(min_offset: float = 0, max_offset: float = 0) -> Vector2:
	return Vector2(
		randf_range(bar_min_x + min_offset, bar_max_x - max_offset),
		9 # centralizado
	)

# Retorna se pode ter caracteres da tela amaldiçoada na tela
func can_have_bad_chars() -> bool:
	return\
		(not GameManager.settings.has("flashing_elements"))\
		or (GameManager.settings.has("flashing_elements") and GameManager.settings['flashing_elements'])
