class_name Maze extends Node2D

var maze : Array
var tile_scale : float = 375

func _ready() -> void:
	maze = read_maze()


func read_maze() -> Array:
	# Variáveis de controle
	var height: int
	var width: int
	var matrix = []

	# Obtém a textura do labrinto.
	var maze_texture: Texture2D = $MazeBitmap.texture
	height = maze_texture.get_height()
	width = maze_texture.get_width()

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
