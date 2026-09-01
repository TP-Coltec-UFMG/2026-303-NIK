class_name Maze extends Node2D

var maze : Array
var tile_scale : float = 375
var height: int
var width: int
var pos_item1 : Vector2i
var pos_item2 : Vector2i
var pos_item3 : Vector2i

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
				column.append(maze_bitmap.get_bit(c, r))
			matrix.append(column)

	return matrix


func is_walkable(column: int, row: int):
	if !maze[column][row]: return true
	else: return false

func check_item_pickup(column: int, row: int) -> void:
	if column == pos_item1.x and row == pos_item1.y and is_instance_valid($item1):
		$item1.queue_free()
	if column == pos_item2.x and row == pos_item2.y and is_instance_valid($item2):
		$item2.queue_free()
	if column == pos_item3.x and row == pos_item3.y and is_instance_valid($item3):
		$item3.queue_free()


func roll_pos_items() -> void:
	while true:
		pos_item1 = Vector2(randi_range(27, 31), randi_range(1, 5))
		if !maze[pos_item1.x][pos_item1.y]:
			$item1.position = (Vector2(pos_item1) + Vector2(0.5, 0.5)) * tile_scale
			break

	while true:
		pos_item2 = Vector2(randi_range(1, 5), randi_range(27, 31))
		if !maze[pos_item2.x][pos_item2.y]:
			$item2.position = (Vector2(pos_item2) + Vector2(0.5, 0.5)) * tile_scale
			break

	while true:
		pos_item3 = Vector2(randi_range(27, 31), randi_range(27, 31))
		if !maze[pos_item3.x][pos_item3.y]:
			$item3.position = (Vector2(pos_item3) + Vector2(0.5, 0.5)) * tile_scale
			break
