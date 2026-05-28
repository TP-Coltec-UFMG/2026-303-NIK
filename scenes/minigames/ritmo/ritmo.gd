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

@export var ataque : BotaoRitmo
@export var defesa : BotaoRitmo
@export var vida : BotaoRitmo

@onready var ui : CanvasLayer = $UI
@onready var barra_nikole : Barra = $UI/VidaNikole
@onready var barra_inimigo : Barra = $UI/VidaInimigo

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.is_pressed() and not event.is_echo():
			vida.adicionar_nota(10)
		if event.keycode == KEY_RIGHT and event.is_pressed() and not event.is_echo():
			ataque_inimigo(10, randi_range(1, 4), 0.2)

func ataque_inimigo(dano : float, numero_ataques : int = 1, intervalo : float = 0.0):
	for i in range(numero_ataques):
		defesa.adicionar_nota(dano)
		if not i == numero_ataques - 1:
			await get_tree().create_timer(intervalo).timeout

func _ready() -> void:
	get_tree().root.content_scale_factor = 1

	await get_tree().create_timer(2).timeout
	while vida_nikole > 0 and vida_inimigo > 0:
		ataque_inimigo(5, randi_range(1, 4), 0.25)
		await get_tree().create_timer(1).timeout
		ataque_nikole()
		await get_tree().create_timer(.15 * 5).timeout

func ataque_nikole():
	for i in range(4):
		ataque.adicionar_nota(5)
		if not i == 3:
			await get_tree().create_timer(0.15).timeout
