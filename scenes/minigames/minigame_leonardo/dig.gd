# Nome da classe
class_name Dig extends Node2D

# Sprites do background para o efeito de descida
@export var surface : Sprite2D
@export var earth1 : Sprite2D
@export var earth2 : Sprite2D
@export var hole1 : Sprite2D
@export var hole2 : Sprite2D
@export var root : Sprite2D
@export var panel : PanelContainer

# Constantes
const LETTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"  # Alfabeto para o sorteio da letra.
const TIME_TO_QTE : float = 2  # Tempo entre os QTE em segundos.
const DIG_DISTANCE : float = 200.0  # Distância da descida em unidades.

# Variáveis de controle
var time_to_qte : float  # Variável de modificação para a contagem do tempo.
var qte_passed : int = 0  # Quantidade de qte passados.
var reach_final_course : bool = false  # Determina quando o fundo com a raíz deve aparecer.
var second_background : int = 0 # Determina o fundo de terra q está depois para colocar as raízes abaixo.
var active_qte : bool = false  # Impede que outro qte seja sorteado.
var active_game : bool = true  # Determina o fim do jogo.
var label : Label  # Label do Painel que mostra a tecla do qte.

func _ready() -> void:
	# Inicialização de algumas variáveis.
	time_to_qte = TIME_TO_QTE
	panel.scale = Vector2(0, 0)
	panel.visible = false
	label = panel.get_node("Label")
	
	# Garante a posição correta de alguns dos fundos.
	surface.position.x = 0
	earth1.position.x = 0
	earth2.position.x = 0

func _process(delta: float) -> void:
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
	if qte_passed == 20:
		DialogueController.start_dialogue("leonardo_minigame_dialogue_4")
		await DialogueController.dialogue_finished
		reach_final_course = true
	
	# Diminui o tempo para o próximo qte.
	time_to_qte -= delta
	
	if !reach_final_course:
		# Repete o fundo conforme ele sai da tela.
		# OBS: substituir os valores abaixo conforme o indicado:
		# -2000 -> posição da câmera - tamanho vertical do sprite.
		# 2872 -> tamanho vertical do sprite.
		if earth1.position.y <= -2000:
			earth1.position.y = earth2.position.y + 2872
			second_background = 1
		if earth2.position.y <= -2000:
			earth2.position.y = earth1.position.y + 2872
			second_background = 2
	else:
		root.position.x = 0
		if second_background == 1: root.position.y = earth1.position.y + 3236
		elif second_background == 2: root.position.y = earth2.position.y + 3236
	
	# Repete o fundo do buraco conforme ele sai da tela.
	# OBS: substituir os valores abaixo conforme o indicado:
	# -1000 -> posição da câmera - tamanho vertical do sprite.
	# 932.4 -> tamanho vertical do sprite.
	if hole1.position.y <= -1000:
		hole1.position.y = hole2.position.y + 932.4
	if hole2.position.y <= -1000:
		hole2.position.y = hole1.position.y + 932.4
	
	# Sorteia um outro qte quando o tempo acabar e se já não tiver um ativo.
	if time_to_qte <= 0 and active_game and !active_qte:
		time_to_qte = TIME_TO_QTE
		roll_qte()
	
	if root.position.y == 631.0:
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
	
	# Tween para a aparição do comando na tela.
	var tween : Tween = panel.create_tween()
	tween\
		.tween_property(panel, "scale", Vector2(1, 1), 0.8)\
		.set_trans(Tween.TRANS_ELASTIC)\
		.set_ease(Tween.EASE_OUT)
	
	# Alteração das variáveis de controle.
	active_qte = true
	panel.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo:
		# Compara a tecla pressionada com a sorteada.
		var pressed_key = event.as_text_keycode().to_upper()
		if pressed_key == label.text: await qte_success()  # Sucesso.
		else: await qte_failure()  # Falha.
		
		# Tween de desaparecimento do comando.
		var tween : Tween = panel.create_tween()
		tween\
			.tween_property(panel, "scale", Vector2(0, 0), 0.2)\
			.set_ease(Tween.EASE_OUT)
		await tween.finished
		
		# Alteração das variáveis de controle.
		active_qte = false
		panel.visible = false
		label.text = ""

func qte_success() -> void:
	# Tween para fazer o comando piscar verde.
	var tween : Tween = panel.create_tween()
	tween\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(panel, "modulate", Color.LIME_GREEN, 0.15)
	tween.tween_property(panel, "modulate", Color.WHITE, 0.15)
	await tween.finished
	
	# Movimentação.
	surface.position.y -= DIG_DISTANCE
	earth1.position.y -= DIG_DISTANCE
	earth2.position.y -= DIG_DISTANCE
	hole1.position.y -= DIG_DISTANCE
	hole2.position.y -= DIG_DISTANCE
	# Contagem.
	qte_passed += 1
	
func qte_failure() -> void:
	# Tween para fazer o comando piscar vermelho.
	var tween : Tween = panel.create_tween()
	tween\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(panel, "modulate", Color.RED, 0.15)
	tween.tween_property(panel, "modulate", Color.WHITE, 0.15)
	await tween.finished
