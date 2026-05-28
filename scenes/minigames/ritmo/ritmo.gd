extends Node3D

@export var ataque : BotaoRitmo
@export var defesa : BotaoRitmo
@export var vida : BotaoRitmo

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.is_pressed() and not event.is_echo():
			vida.adicionar_nota(0)
		if event.keycode == KEY_RIGHT and event.is_pressed() and not event.is_echo():
			ataque_inimigo(10, randi_range(1, 4), 0.25)

func ataque_inimigo(dano : float, numero_ataques : int = 1, intervalo : float = 0.0):
	for i in range(numero_ataques):
		defesa.adicionar_nota(dano)
		if not i == numero_ataques - 1:
			await get_tree().create_timer(intervalo).timeout
