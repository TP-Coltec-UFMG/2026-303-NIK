extends Node3D
class_name Ritmo

var vida_nikole : float = 100:
	set(valor):
		vida_nikole = valor
		barra_nikole.preenchimento = valor / 100

var vida_inimigo : float = 100:
	set(valor):
		vida_inimigo = valor
		barra_inimigo.preenchimento = valor / 100

var som_nikole = preload("res://scenes/minigames/ritmo/ataque_nikole.wav")
var som_nikole_critico = preload("res://scenes/minigames/ritmo/ataque_nikole_critico.wav")

var som_vorkaro = preload("res://scenes/minigames/ritmo/ataque_vorkaro.wav")
var som_vorkaro_critico = preload("res://scenes/minigames/ritmo/ataque_vorkaro_critico.wav")

var som_cura = preload("res://scenes/minigames/ritmo/cura.wav")

@export var pista_ataque : BotaoRitmo
@export var pista_defesa : BotaoRitmo
@export var pista_cura : BotaoRitmo

@onready var ui : CanvasLayer = $UI
@onready var barra_nikole : Barra = $UI/VidaNikole
@onready var barra_inimigo : Barra = $UI/VidaInimigo

var audio_player_nikole = AudioStreamPlayer.new()
var audio_player_vorkaro = AudioStreamPlayer.new()
var audio_player_cura = AudioStreamPlayer.new()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.is_pressed() and not event.is_echo():
			pista_cura.adicionar_nota(10)
		if event.keycode == KEY_RIGHT and event.is_pressed() and not event.is_echo():
			ataque_inimigo(40, randi_range(1, 4), 0.2)

func ataque_inimigo(dano : float, duracao : int = 1, intervalo : float = 0.0):
	pista_defesa.adicionar_nota(dano)
	var pulou = false
	for i in range(duracao - 2):
		if randi() % 4 == 0 and not pulou:
			pulou = true
			await get_tree().create_timer(intervalo).timeout
		elif randi() % 2 > 0:
			pulou = false
			if randi() % 2 == 0:
				await get_tree().create_timer(intervalo / 2).timeout
				pista_cura.adicionar_nota(dano)
				await get_tree().create_timer(intervalo / 2).timeout
				pista_defesa.adicionar_nota(dano)
			else:
				await get_tree().create_timer(intervalo).timeout
				pista_defesa.adicionar_nota(dano)
		else:
			if randi() % 3 == 0:
				await get_tree().create_timer(intervalo / 2).timeout
				pista_cura.adicionar_nota(dano)
				await get_tree().create_timer(intervalo / 2).timeout
				if randi() % 4 == 0:
					pista_defesa.adicionar_nota(dano)
				else:
					pista_ataque.adicionar_nota(dano/3)
			else:
				await get_tree().create_timer(intervalo).timeout
				pista_ataque.adicionar_nota(dano/3)
	await get_tree().create_timer(intervalo).timeout
	pista_ataque.adicionar_nota(dano/3)

func _ready() -> void:
	get_tree().root.content_scale_factor = 1

	add_child(audio_player_nikole)
	add_child(audio_player_vorkaro)
	add_child(audio_player_cura)

	pista_ataque.acerto.connect(ataque)
	pista_defesa.acerto.connect(defesa)
	pista_defesa.erro.connect(erro_defesa)
	pista_cura.acerto.connect(cura)

	await get_tree().create_timer(2).timeout
	while vida_nikole > 0 and vida_inimigo > 0:
		await ataque_inimigo(5, 4 * randi_range(2, 4), 0.25)
		await get_tree().create_timer(2).timeout

func ataque_nikole():
	for i in range(4):
		pista_ataque.adicionar_nota(5)
		if not i == 3:
			await get_tree().create_timer(0.30).timeout

func ataque(valor : float, critico : bool):
	vida_inimigo -= valor
	audio_player_nikole.stream = som_nikole# if not critico else som_nikole_critico
	audio_player_nikole.play()

func defesa(valor : float, critico : bool):
	vida_nikole -= valor * (0.0 if critico else 0.5)
	audio_player_vorkaro.stream = som_vorkaro# if not critico else som_vorkaro_critico
	audio_player_vorkaro.play()

func cura(valor : float, critico : bool):
	vida_nikole += valor * 1.25 if critico else 1.0
	audio_player_cura.stream = som_cura# if not critico else som_vorkaro_critico
	audio_player_cura.play()

func erro_defesa(valor : float):
	vida_nikole -= valor