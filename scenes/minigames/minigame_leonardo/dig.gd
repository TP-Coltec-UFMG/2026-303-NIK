# Nome da classe
class_name Dig extends Node2D

# Sprites do background para o efeito de descida
@onready var surface : Sprite2D = $Background/Surface
@onready var earth : Sprite2D = $Background/Earth
@onready var hole : Sprite2D = $Background/Hole
@onready var hole_bottom : Sprite2D = $Background/HoleBottom
@onready var root : Sprite2D = $Background/Root
@onready var qte_rect : TextureProgressBar = $CanvasLayer/QTE
@onready var nikole : Area2D = $Nikole

# Constantes
const LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"  # Alfabeto para o sorteio da letra.
const TIME_TO_QTE : float = .125  # Tempo entre os QTE em segundos.
const QTE_DURATION : float = 2  # Tempo entre os QTE em segundos.
const DIG_DISTANCE : float = 270.0  # Distância da descida em unidades.

# Variáveis de controle
var time_to_qte : float  # Variável de modificação para a contagem do tempo.
var qte_passed : int = 0  # Quantidade de qte passados.
var reach_final_course : bool = false  # Determina quando o fundo com a raíz deve aparecer.
var second_background : int = 0 # Determina o fundo de terra q está depois para colocar as raízes abaixo.
var active_qte : bool = false  # Impede que outro qte seja sorteado.
var active_game : bool = false  # Determina o fim do jogo.
var label : Label  # Label do Painel que mostra a tecla do qte.

signal qte_finished # Sinal pra quando o QTE acaba, com sucesso ou derrota

func _ready() -> void:
	# Inicialização de algumas variáveis.
	time_to_qte = TIME_TO_QTE
	qte_rect.scale = Vector2(0, 0)
	qte_rect.visible = false
	label = qte_rect.get_node("Label")
	
	# Garante a posição correta de alguns dos fundos.
	surface.position.x = 0
	earth.position.x = -640

func _process(delta: float) -> void:	
	# Diminui o tempo para o próximo qte.
	if DialogueController.active_dialogue == null and not active_qte and active_game:
		time_to_qte -= delta
	
	# Sorteia um outro qte quando o tempo acabar e se já não tiver um ativo.
	if time_to_qte <= 0 and active_game and !active_qte:
		time_to_qte = TIME_TO_QTE + QTE_DURATION
		roll_qte()
	
	if root.position.y <= 631.0:
		# Para o jogo.
		active_game = false
		# Timer legal.
		await get_tree().create_timer(1).timeout
		# Volta pro mundo normal
		GameManager.load_map()
		GameManager.set_game_data("leonardo_minigame_completed", true)
		DialogueController.start_dialogue("leonardo_post_minigame")

func roll_qte() -> void:
	# Escolhe uma letra aleatória.
	var rand_i = randi() % LETTERS.length()
	var rand_letter = LETTERS[rand_i]
	label.text = rand_letter
	qte_rect.value = 100
	qte_rect.offset_transform_position = Vector2(0, 0)
	
	# Tween para a aparição do comando na tela.
	var tween : Tween = qte_rect.create_tween()
	tween\
		.tween_property(qte_rect, "scale", Vector2(1, 1), 0.4)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(qte_rect, 'offset_transform_position', Vector2(-qte_rect.size.x/2, qte_rect.size.x/2), 0.4)

	var tween_progress : Tween = qte_rect.create_tween()
	tween_progress\
		.tween_property(qte_rect, 'value', 0, QTE_DURATION)\
		.set_trans(Tween.TRANS_LINEAR)\
		.set_ease(Tween.EASE_OUT)
		
	# Alteração das variáveis de controle.
	active_qte = true
	qte_rect.visible = true

	var qte_status = { "running" : true}

	var clear_binds = func():
		if qte_status.running:
			qte_status.running = false
			if tween_progress.is_valid():
				tween_progress.kill()

	qte_finished.connect(clear_binds, CONNECT_ONE_SHOT)
	tween_progress.finished.connect(clear_binds, CONNECT_ONE_SHOT)

	while qte_status.running:
		await get_tree().process_frame
	
	if active_qte:
		qte_failure()
		active_qte = false

func _unhandled_input(event: InputEvent) -> void:
	if active_qte and event is InputEventKey and event.pressed and not event.echo:
		# Compara a tecla pressionada com a sorteada.
		var pressed_key = event.as_text_keycode().to_upper()
		if pressed_key not in LETTERS:
			print("ta chapando ze que botao é esse q c aperto")
			return

		active_qte = false

		if pressed_key == label.text: await qte_success()  # Sucesso.
		else: await qte_failure()  # Falha.
		
		# Alteração das variáveis de controle.
		qte_rect.visible = false
		label.text = ""

func qte_success() -> void:
	qte_finished.emit()
	# Contagem.
	qte_passed += 1

	# Tween para fazer o comando piscar verde.
	var tween : Tween = qte_rect.create_tween()
	tween\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(qte_rect, "modulate", Color.LIME_GREEN, 0.15)
	tween.tween_property(qte_rect, "modulate", Color.WHITE, 0.15)
	await tween.finished
	
	# Movimentação.
	hole.region_rect.size.y += DIG_DISTANCE
	hole_bottom.position.y += DIG_DISTANCE
	nikole.position.y += DIG_DISTANCE
		
	# Tween de desaparecimento do comando.
	tween.kill()
	tween = qte_rect.create_tween()
	tween\
		.tween_property(qte_rect, "scale", Vector2(0, 0), 0.2)\
		.set_ease(Tween.EASE_OUT)
	await tween.finished
	
	# Verificação dos qte para os diálogos.
	if qte_passed == 5:
		DialogueController.start_dialogue("leonardo_minigame_dialogue_1")
		await DialogueController.dialogue_finished
	if qte_passed == 10:
		DialogueController.start_dialogue("leonardo_minigame_dialogue_2")
		await DialogueController.dialogue_finished
	if qte_passed == 15:
		DialogueController.start_dialogue("leonardo_minigame_dialogue_3")
		await DialogueController.dialogue_finished
		reach_final_course = true
	
func qte_failure() -> void:
	qte_finished.emit()
	# Tween para fazer o comando piscar vermelho.
	var tween : Tween = qte_rect.create_tween()
	tween\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(qte_rect, "modulate", Color.RED, 0.15)
	tween.tween_property(qte_rect, "modulate", Color.WHITE, 0.15)
	await tween.finished
		
	# Tween de desaparecimento do comando.
	tween.kill()
	tween = qte_rect.create_tween()
	tween\
		.tween_property(qte_rect, "scale", Vector2(0, 0), 0.2)\
		.set_ease(Tween.EASE_OUT)
	await tween.finished

func _on_play_pressed():
	$Tutorial.visible = false

	# Dá um tempo entre o play e o jogo realmente começar
	await get_tree().create_timer(1).timeout
	active_game = true
