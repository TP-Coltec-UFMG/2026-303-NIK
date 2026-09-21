# Código responsável por gerar tarefas (no caso, cartas) aleatoriamente no monitor
extends Node2D

# Tempo mínimo/máximo entre tarefas (em segundos)
const MIN_TIME_BETWEEN_TASKS : float = 0.9
const MAX_TIME_BETWEEN_TASKS : float = 2

# Tempo que da animação da tarefa aparecer/desaparecer
const TASK_ANIMATION_TIME : float = 0.5

# Quantas tarefas o usuário precisa fazer para terminar o minigame
const NUMBER_OF_TASKS : int = 30

# Cantos seguros do monitor (que serão usados para colocar as tarefas)
@onready var safe_monitor_upper_left : Vector2 = $UpperLeftCorner.get_global_transform_with_canvas().origin
@onready var safe_monitor_lower_right : Vector2 = $LowerRightCorner.get_global_transform_with_canvas().origin

# Exemplar de carta
@onready var letter_example : TextureButton = $LetterExample
# Lugar onde vai colocar as tarefas
@onready var tasks_node : CanvasLayer = $Tasks
# Texto que mostra o progresso do minigame
@onready var progress_label : Label = $Tasks/HBoxContainer/ProgressLabel

# Se o minigame está rodando (se consegue gerar mais tarefas ou gerar o skill check)
var is_minigame_running : bool = true
# Quantidade de tasks que foram criadas
var tasks_generated : int = 0
# Quantidade de tasks que foram completadas
var tasks_completed : int = 0

# Tempo até a próxima tarefa ser gerada
var next_task_time : float = 99

func _ready() -> void:
	next_task_time = randf_range(MIN_TIME_BETWEEN_TASKS, MAX_TIME_BETWEEN_TASKS)
	progress_label.text = "0/%d" % NUMBER_OF_TASKS


func _process(delta: float) -> void:
	next_task_time -= delta

	# Se já deu tempo de gerar outra tarefa, gera ela
	if next_task_time < 0 and tasks_generated < NUMBER_OF_TASKS and is_minigame_running:
		# Obtém um novo tempo para a próxima tarefa 
		next_task_time = randf_range(MIN_TIME_BETWEEN_TASKS, MAX_TIME_BETWEEN_TASKS)
		# Gera a carta
		generate_letter()

# Gera uma carta em um lugar aleatório do monitor
func generate_letter() -> void:
	var clone : TextureButton = letter_example.duplicate()

	# Obtém uma posição aleatória no monitor
	clone.set_position(get_random_position_on_monitor())

	# Conecta o clique
	clone.pressed.connect(on_task_clicked.bind(clone))

	clone.scale = Vector2(0, 0)
	# Cria e configura o tween de aparecer
	var tween : Tween = clone.create_tween()
	tween\
		.tween_property(clone, "scale", Vector2(1, 1), TASK_ANIMATION_TIME)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)

	# Coloca o clone no tasks_node
	tasks_node.add_child(clone)

	tasks_generated += 1

# Obtém uma posição aleatória na área segura do monitor.
# NOTA: idealmente, essa função deveria retornar uma posição que não
#       está sendo usada por nada (não tem uma tarefa tocando aquela posição)
#       para evitar sobreposições. No entanto, isso é realmente necessário? 😭
func get_random_position_on_monitor() -> Vector2:
	return Vector2(
		randf_range(safe_monitor_upper_left.x, safe_monitor_lower_right.x),
		randf_range(safe_monitor_upper_left.y, safe_monitor_lower_right.y)
	)

	
# Quando uma task for clicada, essa função será chamada
func on_task_clicked(task_button : TextureButton) -> void:
	tasks_completed += 1
	task_button.disabled = true

	# Atualiza o label do progresso
	progress_label.text = "%d/%d" % [tasks_completed, NUMBER_OF_TASKS]

	var tween : Tween = task_button.create_tween()
	tween\
		.tween_property(task_button, "scale", Vector2(0, 0), TASK_ANIMATION_TIME)\
		.set_trans(Tween.TRANS_CIRC)\
		.set_ease(Tween.EASE_IN_OUT)

	# Quando terminar o tween, dá queue_free
	tween.tween_callback(task_button.queue_free)
	tween.tween_callback(handle_task_completion)

# Lida com ações quando uma tarefa é completada (como se é 
# pra mostrar um diálogo ou acabar o minigame)
func handle_task_completion() -> void:
	# Se chegou na meta de tarefas
	if tasks_completed >= NUMBER_OF_TASKS:
		GameManager.load_map()
		GameManager.set_game_data("alex_minigame_completed", true)
		DialogueController.start_dialogue("alex_post_minigame")

	# Lida com os diálogos	
	if tasks_completed == 10: # se 10 tarefas foram completadas
		is_minigame_running = false
		DialogueController.start_dialogue("alex_minigame_dialogue_1")
		await DialogueController.dialogue_finished
		is_minigame_running = true
		
	elif tasks_completed == 20: # se 20 tarefas foram completadas
		is_minigame_running = false
		DialogueController.start_dialogue("alex_minigame_dialogue_2")
		await DialogueController.dialogue_finished
		is_minigame_running = true
