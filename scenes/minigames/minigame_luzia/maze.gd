class_name Maze extends Node2D

@onready var nikole : NikoleMaze = $Nikole
var maze : Array
var tile_scale : float = 375
var height: int
var width: int

var has_francisco = false
var has_luis = false
var has_flavia = false

var dropped_francisco = false
var dropped_luis = false
var dropped_flavia = false

const pos_star_nikole = Vector2i(1, 1)
const pos_star_francisco = Vector2i(4, 13)
const pos_star_luis = Vector2i(30, 18)
const pos_star_flavia = Vector2i(19, 1)

var pos_francisco : Vector2i
var pos_luis : Vector2i
var pos_flavia : Vector2i

@export var estrela_ligada_nikole : Texture
@export var estrela_ligada_francisco : Texture
@export var estrela_ligada_luis : Texture
@export var estrela_ligada_flavia : Texture

@onready var tutorial_button : Button = $UI/Background/Play

func _ready() -> void:
	tutorial_button.connect("pressed", start_game)
	get_tree().paused = true

	maze = read_maze()
	maze[pos_star_nikole.x][pos_star_nikole.y] = 13
	maze[pos_star_francisco.x][pos_star_francisco.y] = 10
	maze[pos_star_luis.x][pos_star_luis.y] = 20
	maze[pos_star_flavia.x][pos_star_flavia.y] = 30
	roll_pos_kids()
	initialize_pathfinding()

func start_game():
	$UI.visible = false
	get_tree().paused = false


func read_maze() -> Array:
	# Obtém a textura do labrinto.
	var maze_texture: Texture2D = $MazeBitmap.texture
	height = maze_texture.get_height()
	width = maze_texture.get_width()
	var matrix = []

	if maze_texture:
		# Obtém a imagem da mazé e cria um bitmap a partir disso.
		var maze_image: Image = maze_texture.get_image()
		var maze_bitmap = BitMap.new()
		maze_bitmap.create_from_image_alpha(maze_image)
		# Passa os dados do bitmap para uma outra matriz.
		for c in range(width):
			var column = []
			for r in range(height):
				column.append(-1 if maze_bitmap.get_bit(c, r) else 0)
			matrix.append(column)

	return matrix

func try_walk(column: int, row: int):
	if maze[column][row] == -1: return false
	else: return true

func check_kid_pickup(column: int, row: int) -> void:
	match maze[column][row]:
		1:
			$Francisco.collected = true
			maze[column][row] = 0
			has_francisco = true
			nikole.targets[0] = $Stars/FranciscoS.position
		2:
			$Luis.collected = true
			maze[column][row] = 0
			maze[column][row] = 0
			has_luis = true
			nikole.targets[1] = $Stars/LuisS.position 
		3:
			$Flavia.collected = true
			maze[column][row] = 0
			maze[column][row] = 0
			has_flavia = true
			nikole.targets[2] = $Stars/FlaviaS.position

func check_kid_dropout(column: int, row: int) -> bool:
	match maze[column][row]:
		10:
			if has_francisco:
				$Francisco.target_pos = (Vector2(pos_star_francisco) + Vector2(0.5, 0.5)) * tile_scale
				$Francisco.placed = true
				has_francisco = false
				dropped_francisco = true
				$Stars/FranciscoS.texture = estrela_ligada_francisco
				wait_a_lil_time_and_start_dialogue("luzia_francisco")
				return true
		20:
			if has_luis:
				$Luis.target_pos = (Vector2(pos_star_luis) + Vector2(0.5, 0.5)) * tile_scale
				$Luis.placed = true
				has_luis = false
				dropped_luis = true
				$Stars/LuisS.texture = estrela_ligada_luis
				wait_a_lil_time_and_start_dialogue("luzia_luis")
				return true
		30:
			if has_flavia:
				$Flavia.target_pos = (Vector2(pos_star_flavia) + Vector2(0.5, 0.5)) * tile_scale
				$Flavia.placed = true
				has_flavia = false
				dropped_flavia = true
				$Stars/FlaviaS.texture = estrela_ligada_flavia
				wait_a_lil_time_and_start_dialogue("luzia_flavia")
				return true
	return false

func check_end_game(column: int, row: int, force : bool = false) -> void:
	if force:
		GameManager.load_map()
		GameManager.set_game_data("luzia_minigame_completed", true);
		DialogueController.start_dialogue("luzia_post_minigame")
	if $Francisco.placed and $Luis.placed and $Flavia.placed:
		$Stars/NikoleS.texture = estrela_ligada_nikole
		if maze[column][row] == 13:
			GameManager.load_map()
			GameManager.set_game_data("luzia_minigame_completed", true);
			DialogueController.start_dialogue("luzia_post_minigame")

func roll_pos_kids() -> void:
	while true:
		pos_francisco = Vector2i(randi_range(27, 31), randi_range(1, 5))
		if maze[pos_francisco.x][pos_francisco.y] == 0:
			$Francisco.position = (Vector2(pos_francisco) + Vector2(0.5, 0.5)) * tile_scale
			maze[pos_francisco.x][pos_francisco.y] = 1
			break

	while true:
		pos_luis = Vector2i(randi_range(1, 5), randi_range(27, 31))
		if maze[pos_luis.x][pos_luis.y] == 0:
			$Luis.position = (Vector2(pos_luis) + Vector2(0.5, 0.5)) * tile_scale
			maze[pos_luis.x][pos_luis.y] = 2
			break

	while true:
		pos_flavia = Vector2i(randi_range(27, 31), randi_range(27, 31))
		if maze[pos_flavia.x][pos_flavia.y] == 0:
			$Flavia.position = (Vector2(pos_flavia) + Vector2(0.5, 0.5)) * tile_scale
			maze[pos_flavia.x][pos_flavia.y] = 3
			break
	nikole.targets[0] = $Francisco.position
	nikole.targets[1] = $Luis.position 
	nikole.targets[2] = $Flavia.position

func wait_a_lil_time_and_start_dialogue(dialogua_name : String) -> void:
	await get_tree().create_timer(0.5).timeout
	DialogueController.start_dialogue(dialogua_name)


# Grid do pathfinding (que usa A*)
var _astar_grid : AStarGrid2D = AStarGrid2D.new()
# Cache do pathfinding, para não gastar tempo calculando 
# algo que já foi calculado
var _pathfinding_cache: Dictionary = {}
# Coordenadas (início e fim) do caminho que está sendo mostrado atualmente
var _current_path_coordinates : Vector4i
# Caminho que está atualmente sendo mostrado
var current_path : Array[Vector2i]

# Obtém o caminho possivelmente mais rápido de `from` até `to`, retornando
# um array de posições. Se esse caminho já foi calculado, retorna o caminho
# já calculado. Se não, calcula o caminho.
# NOTA: como as paredes do labirinto nunca mudam, usar essa técnica é seguro.
func _calculate_path(from : Vector2i, to : Vector2i) -> Array[Vector2i]:
	# Obtém uma chave que identifica o ponto de partida e de chegada
	var cache_key = Vector4i(from.x, from.y, to.x, to.y)

	# Se já foi calculado, retorna o já calculado
	if _pathfinding_cache.has(cache_key):
		return _pathfinding_cache[cache_key]

	# Se chegou até aqui, não foi calculado. Então, calcula.
	var new_path = _astar_grid.get_id_path(from, to)
	_pathfinding_cache[cache_key] = new_path
	return new_path

func initialize_pathfinding() -> void:
	# Define a borda e o tamanho das células do grid
	_astar_grid.region = Rect2i(0, 0, width, height)
	_astar_grid.cell_size = Vector2(tile_scale, tile_scale)
	
	# Determina o modo de movimento
	_astar_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_NEVER 
	
	# Inicializa o grid
	_astar_grid.update()

	# Coloca as paredes
	for c in range(width):
		for r in range(height):
			_astar_grid.set_point_solid( Vector2i(c, r), true if maze[c][r] == -1 else false)

	# Atualiza o grid (com as novas informações de parede e tal)
	_astar_grid.update()

# Obtém o melhor caminho da posição `from` até a `to`, colocando
# ele, por meio de sprites indicativos, no mapa.
# Se precisar mostrar (visualmente) a primeira posição (ou seja, 
# a posição `from`), defina show_first_point como `true`.
func _pathfind(from : Vector2i, to : Vector2i, show_first_point : bool = true, point_color : Color = Color.WHITE) -> void:
	var path_coordinates : Vector4i = Vector4i(from.x, from.y, to.x, to.y)

	# Se o caminho não mudou, não há necessidade de calcular
	if path_coordinates == _current_path_coordinates:
		return

	_current_path_coordinates = path_coordinates
	
	# Obtém o caminho
	current_path = _calculate_path(from, to)

	# Limpa o pathfinding feito antes
	clear_pathfinding()

	# Coloca um sprite de ponto em cada célula
	for pos in current_path:
		# Se a posição do ponto atual for igual a do início
		if !show_first_point and pos == from:
			continue
		# Obtém a posição centralizada na tela
		var real_pos = (Vector2(pos) + Vector2(0.5, 0.5)) * tile_scale
		
		# Cria o sprite e coloca na posição
		var sprite = Sprite2D.new()
		sprite.texture = load("res://sprites/minigames/minigame_luzia/path_point.png")
		sprite.position = real_pos;
		sprite.modulate = point_color;

		$PathfinderPoints.add_child(sprite)

# Mostra o caminho para a tarefa mais próxima
# Se precisar mostrar (visualmente) a primeira posição (ou seja, 
# a posição `from`), defina show_first_point como `true`.
func pathfind_to_nearest_task(from : Vector2i, show_first_point : bool = false) -> void:
	const ignore_position : Vector2i = Vector2i(-1, -3) # valor para indicar que é para pular aquela posição
	var positions : Array[Vector2i] = []
	
	# Adiciona a posição da criança. Se ela já tiver sido pega,
	# adiciona a posição da estrela.
	# NOTA: se a criança já está na estrela, um valor será adicionado
	# 	    na sua respectiva posição (em `positions`) mesmo assim,
	#		para manter o sistema de cores. :P (por isso que existe
	#		o valor `ignore_position`)
	if !dropped_flavia:
		if !has_flavia:
			positions.append(pos_flavia)
		else:
			positions.append(pos_star_flavia)
	else:
		positions.append(ignore_position)

	if !dropped_francisco:
		if !has_francisco:
			positions.append(pos_francisco)
		else:
			positions.append(pos_star_francisco)
	else:
		positions.append(ignore_position)

	if !dropped_luis:
		if !has_luis:
			positions.append(pos_luis)
		else:
			positions.append(pos_star_luis)
	else:
		positions.append(ignore_position)
	
	# Se não há posição, ou seja, pegou todas as crianças e colocou
	# em sua respectiva estrela, mostra o caminho de volta

	# Obtém a posição com o menor caminho
	var best_i : int = -1 # -1 significa que o caminho não encontrou ainda e, portanto, precisa ser inicializado (ou acabou as tarefas)
	var path : Array[Vector2i]
	for i in range(0, positions.size()):
		# Se a posição atual for para ignorar, então pula ela
		if positions[i] == ignore_position:
			continue

		# Calcula o caminho para a i-ésima posição. Se esse 
		# caminho for menor que o atual, define ele como o menor.
		var curr_path : Array[Vector2i] = _calculate_path(from, positions[i])
		if best_i == -1 or curr_path.size() < path.size():
			best_i = i
			path = curr_path

	# Se não encontrou nenhum caminho, é porque acabaram as
	# tarefas. Logo, mostra o caminho para o início.
	if best_i == -1:
		_pathfind(from, Vector2i(1, 1), show_first_point)
		return
	
	var color : Color
	# TODO: colocar as cores certinhas
	match best_i:
		0: # Flávia
			color = Color.MEDIUM_PURPLE
		1: # Francisco
			color = Color.RED
		2: # Luís
			color = Color.YELLOW
	_pathfind(from, positions[best_i], show_first_point, color)


# Limpa todos os pontos visuais do sistema de pathfinding
func clear_pathfinding() -> void:
	# Limpa os pontos antigos
	for child in $PathfinderPoints.get_children():
		child.queue_free()
			
		
		
	
	
