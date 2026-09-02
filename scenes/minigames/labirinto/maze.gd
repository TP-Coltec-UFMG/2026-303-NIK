class_name Maze extends Node2D

var maze : Array
var tile_scale : float = 375
var height: int
var width: int

var has_francisco = false
var has_luis = false
var has_flavia = false

const pos_star_nikole = Vector2i(1, 1)
const pos_star_francisco = Vector2i(4, 13)
const pos_star_luis = Vector2i(30, 18)
const pos_star_flavia = Vector2i(19, 1)

@export var estrela_ligada_nikole : Texture
@export var estrela_ligada_francisco : Texture
@export var estrela_ligada_luis : Texture
@export var estrela_ligada_flavia : Texture

func _ready() -> void:
	maze = read_maze()
	maze[pos_star_nikole.x][pos_star_nikole.y] = 13
	maze[pos_star_francisco.x][pos_star_francisco.y] = 10
	maze[pos_star_luis.x][pos_star_luis.y] = 20
	maze[pos_star_flavia.x][pos_star_flavia.y] = 30
	roll_pos_kids()

func read_maze() -> Array:
	# Obtém a textura do labrinto.
	var maze_texture: Texture2D = $MazeBitmap.texture
	height = maze_texture.get_height()
	width = maze_texture.get_width()
	var matrix = []

	if maze_texture:
		# Obtém a imagem do maze e cria um bitmap a partir disso.
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

func is_walkable(column: int, row: int):
	if maze[column][row] == -1: return false
	else: return true

func check_kid_pickup(column: int, row: int) -> void:
	match maze[column][row]:
		1:
			$Francisco.collected = true
			maze[column][row] = 0
			has_francisco = true
		2:
			$Luis.collected = true
			maze[column][row] = 0
			maze[column][row] = 0
			has_luis = true
		3:
			$Flavia.collected = true
			maze[column][row] = 0
			maze[column][row] = 0
			has_flavia = true

func check_kid_dropout(column: int, row: int) -> void:
	match maze[column][row]:
		10:
			if has_francisco:
				$Francisco.target_pos = (Vector2(pos_star_francisco) + Vector2(0.5, 0.5)) * tile_scale
				$Francisco.placed = true
				has_francisco = false
				$Stars/FranciscoS.texture = estrela_ligada_francisco
		20:
			if has_luis:
				$Luis.target_pos = (Vector2(pos_star_luis) + Vector2(0.5, 0.5)) * tile_scale
				$Luis.placed = true
				has_luis = false
				$Stars/LuisS.texture = estrela_ligada_luis
		30:
			if has_flavia:
				$Flavia.target_pos = (Vector2(pos_star_flavia) + Vector2(0.5, 0.5)) * tile_scale
				$Flavia.placed = true
				has_flavia = false
				$Stars/FlaviaS.texture = estrela_ligada_flavia

func check_end_game(column: int, row: int) -> void:
	if $Francisco.placed and $Luis.placed and $Flavia.placed:
		$Stars/NikoleS.texture = estrela_ligada_nikole
		if maze[column][row] == 13:
			GameManager.load_map()
			GameManager.set_game_data("minigame_dona_luzia_complete", true);

func roll_pos_kids() -> void:
	while true:
		var pos = Vector2i(randi_range(27, 31), randi_range(1, 5))
		if maze[pos.x][pos.y] == 0:
			$Francisco.position = (Vector2(pos) + Vector2(0.5, 0.5)) * tile_scale
			maze[pos.x][pos.y] = 1
			break

	while true:
		var pos = Vector2i(randi_range(1, 5), randi_range(27, 31))
		if maze[pos.x][pos.y] == 0:
			$Luis.position = (Vector2(pos) + Vector2(0.5, 0.5)) * tile_scale
			maze[pos.x][pos.y] = 2
			break

	while true:
		var pos = Vector2i(randi_range(27, 31), randi_range(27, 31))
		if maze[pos.x][pos.y] == 0:
			$Flavia.position = (Vector2(pos) + Vector2(0.5, 0.5)) * tile_scale
			maze[pos.x][pos.y] = 3
			break
