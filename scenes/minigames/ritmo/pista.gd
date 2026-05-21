extends Node2D
class_name Pista

var id : int = 1
@export var cor : Color = Color(1, 0.3, 0.3, 1)
@export var sprite_botao : Texture

var notas : Array[Sprite2D] = [] 


@onready var botao : Sprite2D = $Botao

func _ready() -> void:
	botao.self_modulate = cor
	$Botao/Label.text = MestreSupremo.caractere_tecla(InputMap.action_get_events("ritmo_" + str(id))[0].physical_keycode)

func _process(delta: float) -> void:
	for nota in notas:
		nota.position.y += 500 * delta
		if nota.position.y > 256:
			notas.erase(nota)

func criar_nota():
	# cor.h = wrapf(cor.h + 0.3, 0.0, 1.0)
	# botao.self_modulate = cor

	var sprite = Sprite2D.new()
	sprite.texture = sprite_botao
	sprite.z_index = -1
	sprite.scale.x = 1 / 3.0
	sprite.scale.y = 1 / 3.0
	sprite.position.y = -get_viewport_rect().size.y

	notas.append(sprite)
	add_child(sprite)

func tocar_nota():
	if notas.size() <= 0: return

	var mais_perto = notas[0]
	var menor_distancia = abs(notas[0].position.y - botao.position.y)

	for nota in notas:
		if nota.position.y > menor_distancia: 
			mais_perto = nota
			menor_distancia = nota.position.y

	if menor_distancia < 128:
		notas.erase(mais_perto)
		remove_child(mais_perto)
		mais_perto.queue_free()

func _input(event: InputEvent) -> void:
	if event.is_pressed() and not event.is_echo():
		if event.is_action_pressed("ritmo_" + str(id)):
			tocar_nota()
