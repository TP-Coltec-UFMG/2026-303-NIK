class_name GeradorParede extends Node

@export var cena_parede : PackedScene
const LINHAS = 20
const COLUNAS = 20
const HORIZONTAL = 0
const VERTICAL = 1

var conjuntos = {}
var paredes = {}
var paredes_internas = [] 

func _ready() -> void:
	gerar_paredes()

	for i in range(LINHAS):
		for j in range(COLUNAS):
			var id = i * COLUNAS + j
			conjuntos[id] = {Vector2i(i, j): true}

	paredes_internas.shuffle()

	for id_parede in paredes_internas:
		if conjuntos.size() <= 1: 
			break

		var celula_a : Vector2i
		var celula_b : Vector2i

		if id_parede.z == HORIZONTAL:
			celula_a = Vector2i(id_parede.x, id_parede.y)
			celula_b = Vector2i(id_parede.x, id_parede.y - 1)
		else:
			celula_a = Vector2i(id_parede.x, id_parede.y)
			celula_b = Vector2i(id_parede.x - 1, id_parede.y)

		var dados_conjunto = confere_conjunto(celula_a, celula_b)

		if not dados_conjunto[0]:
			paredes[id_parede].queue_free()
			paredes.erase(id_parede)
				
			var id_conj_a = dados_conjunto[1]
			var id_conj_b = dados_conjunto[2]

			conjuntos[id_conj_a].merge(conjuntos[id_conj_b])
			conjuntos.erase(id_conj_b)


func gerar_paredes():
	# Gera as paredes horizontais.
	for i in range(LINHAS):
		for j in range(COLUNAS + 1):
			var pos = Vector3i(i, j, HORIZONTAL)
			paredes[pos] = instancia_parede(i, j, HORIZONTAL)
			if j > 0 and j < COLUNAS: 
				paredes_internas.append(pos)

	# Gera as paredes verticais.
	for i in range(LINHAS + 1):
		for j in range(COLUNAS):
			var pos = Vector3i(i, j, VERTICAL)
			paredes[pos] = instancia_parede(i, j, VERTICAL)
			if i > 0 and i < LINHAS: 
				paredes_internas.append(pos)


func instancia_parede(i : int, j : int, orientacao : int) -> Node:
	var parede = cena_parede.instantiate()
	add_child(parede)

	var offset = 0.5
	var size_parede = parede.get_node("CollisionShape3D").shape.size
	var pos_x = (i-(offset if orientacao == 1 else 0.0)) * size_parede.x
	var pos_z = (j-(offset if orientacao == 0 else 0.0)) * size_parede.x
	
	parede.position = Vector3(pos_x, 0, pos_z)
	parede.rotation.y = orientacao * PI/2
	return parede


func confere_conjunto(a : Vector2i, b : Vector2i) -> Array:
	var id_conjunto_a = -1
	var id_conjunto_b = -1

	for id in conjuntos:
		if conjuntos[id].has(a):
			id_conjunto_a = id
		if conjuntos[id].has(b):
			id_conjunto_b = id
				
		if id_conjunto_a != -1 and id_conjunto_b != -1:
			break

	if id_conjunto_a == id_conjunto_b:
		return [true]
	else:
		return [false, id_conjunto_a, id_conjunto_b]	