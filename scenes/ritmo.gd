extends Node

@onready var pistas = {
	0: $Pista1,
	1: $Pista2,
	2: $Pista3,
	3: $Pista4
}

@export var musica : String = "bosta"
# CADA FILA DEVE SER FORMATADA DA SEGUINTE FORMA: (PISTA, NOTA, TEMPO DE BATIDAS ATÉ A PRÓXIMA NOTA)
@export var fila_notas : Array[Vector3i] = []
@export var bpm : int = 60

@export var pontos_label : Label
var pontuacao : float = 0.0
var pontos_maximo : int = 0

var delay_batidas : int = 0

func _ready() -> void:
	ler_json(musica)
	pontos_label.text = str("Pontos: ", pontuacao, "/", pontos_maximo)
	tocar()

func ler_json(musica : String):
	var caminho = "res://minigames/ritmo/musicas/" + musica + ".json"
	if FileAccess.file_exists(caminho):
		var arquivo = FileAccess.open(caminho, FileAccess.READ)
		var conteudo = arquivo.get_as_text()
		arquivo.close()
		
		var dados = JSON.parse_string(conteudo)
		if dados == null:
			print_debug("json tá estranho...")
		else:
			bpm = -1
			for nota in dados:
				if bpm == -1:
					bpm = nota.bpm
				else:
					fila_notas.append(Vector3i(nota.x, nota.y, nota.z))
					pontos_maximo += 1
	else:
		print_debug("o arquivo \"" + caminho + "\" não existe!")

func _process(delta: float) -> void:
	pass

func notas_aleatorias() -> void:
	await get_tree().create_timer(0.25).timeout
	var pista = randi_range(0, 3)

	pistas[pista].criar_nota((pista - 2) * 12 + randi_range(0, 12))
	notas_aleatorias()

func tocar() -> void:
	if fila_notas.size() <= 0:
		print_debug("acabou a musica!")
		return
	await get_tree().create_timer(60.0 / bpm).timeout
	while delay_batidas <= 0:
		pistas[fila_notas[0].x].criar_nota(fila_notas[0].y)
		delay_batidas = fila_notas[0].z
		fila_notas.remove_at(0)
	delay_batidas -= 1

	tocar()

func pontuar(pontos : float) -> void:
	pontuacao += pontos
	pontos_label.text = str("Pontos: ", pontuacao, "/", pontos_maximo)
