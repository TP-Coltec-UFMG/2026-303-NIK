class_name Labirinto extends Node2D

var labirinto

func _ready() -> void:
	labirinto = ler_labirinto()


func ler_labirinto():
	# Variáveis de controle
	var altura: int = 16
	var largura: int = 16
	var matriz = []
	# Obtém a textura do labrinto.
	var labirinto_texture: Texture2D = $labirinto_imagem.texture

	if labirinto_texture:
		# Obtém a imagem do labirinto e cria um bitmap a partir disso.
		var labirinto_imagem: Image = labirinto_texture.get_image()
		var labirinto_bitmap = BitMap.new()
		labirinto_bitmap.create_from_image_alpha(labirinto_imagem)
		# Passa os dados do bitmap para uma outra matriz.
		for l in range(altura):
			var linha = []
			for c in range(largura):
				linha.append(labirinto_bitmap.get_bit(c, l))
			matriz.append(linha)

	return matriz


func verificar_caminho(c: int, l: int):
	if !labirinto[c][l]: return true
	else: return false


func transformador(y: int, x: int):
	return [y/450, x/450]
