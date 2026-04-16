extends Node

@onready var pistas = {
	0: $Pista1,
	1: $Pista2,
	2: $Pista3,
	3: $Pista4
}

@export var musica : String = "nome_do_arquivo"
@export var bpm : int = 60

var fila_notas : Array[Vector3i] = []
var delay_notas : float = 0.0

@export var pontos_label : Label
var pontuacao : float = 0.0
var pontos_maximo : int = 0

func _ready() -> void:
	ler_json(musica)
	if pontos_label:
		pontos_label.text = str("Pontos: ", pontuacao, "/", pontos_maximo)
	tocar_ciclo()

func ler_json(nome_musica : String):
	var caminho = "res://minigames/ritmo/musicas/" + nome_musica + ".json"
	if FileAccess.file_exists(caminho):
		var arquivo = FileAccess.open(caminho, FileAccess.READ)
		var texto = arquivo.get_as_text()
		arquivo.close()
		
		var dados = JSON.parse_string(texto)
		
		if dados == null or typeof(dados) != TYPE_DICTIONARY:
			print_debug("esse json ta estranho...")
			return

		bpm = dados["metadata"]["bpm"]
		
		fila_notas.clear()
		if dados.has("notes"):
			for n in dados["notes"]:
				fila_notas.append(Vector3i(n["x"], n["y"], n["z"]))
				
		pontos_maximo = fila_notas.size()
		delay_notas = 0.0
			
	else:
		print_debug("não achei esse arquivo: ", caminho)

func tocar_ciclo() -> void:
	if fila_notas.is_empty():
		print("acabou a música!")
		return

	while not fila_notas.is_empty() and delay_notas <= 0.01:
		var nota_atual = fila_notas.pop_front()
		if pistas.has(nota_atual.x):
			pistas[nota_atual.x].criar_nota(nota_atual.y)
		delay_notas += nota_atual.z 
		
	delay_notas -= 1.0

	await get_tree().create_timer(60.0 / bpm).timeout
	tocar_ciclo()

func pontuar(pontos : float) -> void:
	pontuacao += pontos
	if pontos_label:
		pontos_label.text = str("Pontos: ", int(pontuacao), "/", pontos_maximo)
