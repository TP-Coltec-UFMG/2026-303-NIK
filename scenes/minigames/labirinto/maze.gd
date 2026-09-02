class_name Maze extends Node2D

var maze : Array
var tile_scale : float = 375
var height: int
var width: int

var has_item1 = false
var has_item2 = false
var has_item3 = false

func _ready() -> void:
	maze = read_maze()
	roll_pos_items()


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

func check_item_pickup(column: int, row: int) -> void:
	match maze[column][row]:
		1:
			$item1.collected = true
			maze[column][row] = 0
			has_item1 = true
		2:
			$item2.collected = true
			maze[column][row] = 0
			maze[column][row] = 0
			has_item2 = true
		3:
			$item3.collected = true
			maze[column][row] = 0
			maze[column][row] = 0
			has_item3 = true

	if has_item1 and has_item2 and has_item3:
		GameManager.load_map()
		GameManager.set_game_data("minigame_dona_luzia_complete", true);

func roll_pos_items() -> void:
	while true:
		# var pos = Vector2i(2, 3)
		var pos = Vector2i(randi_range(27, 31), randi_range(1, 5))
		if maze[pos.x][pos.y] == 0:
			$item1.position = (Vector2(pos) + Vector2(0.5, 0.5)) * tile_scale
			maze[pos.x][pos.y] = 1
			break

	while true:
		var pos = Vector2i(randi_range(1, 5), randi_range(27, 31))
		if maze[pos.x][pos.y] == 0:
			$item2.position = (Vector2(pos) + Vector2(0.5, 0.5)) * tile_scale
			maze[pos.x][pos.y] = 2
			break

	while true:
		var pos = Vector2i(randi_range(27, 31), randi_range(27, 31))
		if maze[pos.x][pos.y] == 0:
			$item3.position = (Vector2(pos) + Vector2(0.5, 0.5)) * tile_scale
			maze[pos.x][pos.y] = 3
			break
