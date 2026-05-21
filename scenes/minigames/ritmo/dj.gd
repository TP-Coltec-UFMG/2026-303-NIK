extends Control

@export_range(1, 6) var numero_de_pistas : int = 3
@export var pista_prefab : PackedScene
@export var espacamento_maximo : int = 256

@onready var pistas_container : Control = $Pistas
var pistas : Array[Pista]
var fila : Array[Array]

func _ready() -> void:
	var espacamento = pistas_container.size.x / (numero_de_pistas - 1)
	var offset = 0
	if espacamento > espacamento_maximo:
		offset = pistas_container.size.x - (espacamento_maximo * (numero_de_pistas - 1))
		espacamento = (pistas_container.size.x - offset) / (numero_de_pistas - 1)

	var tamanho_tela = get_viewport_rect().size

	var offset_hue = randf()

	pistas = []
	for i in range(numero_de_pistas -1, -1, -1):
		var pista = pista_prefab.instantiate() as Pista
		pista.position = Vector2(pistas_container.size.x - i * espacamento - 64, pistas_container.size.y - 128)
		pista.id = numero_de_pistas - i
		pista.cor = Color.from_hsv(offset_hue + i * 1.0 / numero_de_pistas, 0.7, 1.0)
		pistas.append(pista)

		pistas_container.add_child(pista)

	for j in range(32):
		fila.append([] as Array[bool])
		for i in range(numero_de_pistas):
			fila[j].append(true if randf() < pow(0.7, numero_de_pistas) else false)

	comecar_musica()

func comecar_musica():
	if fila.size() <= 0: return

	var notas = fila.pop_front()
	for i in range(numero_de_pistas):
		if notas[i]:
			pistas[i].criar_nota()

	await get_tree().create_timer(0.2).timeout
	comecar_musica()
