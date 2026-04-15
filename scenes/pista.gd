class_name Pista extends Node3D

@onready var fundo = $Fundo
@onready var botao = $Botao
@export var label_prefab : PackedScene
@export var nota_prefab : PackedScene
@export var input: String

signal nota_tocada(pontos : int)

var notas_ativas: Array[Nota] = []
@export var area_clique_perdao: float = 1.25

func _ready() -> void:
	sintetizador.play()
	playback = sintetizador.get_stream_playback()
	nota_tocada.connect(get_parent().pontuar)

func _process(delta: float) -> void:
	fundo.get_active_material(0).uv1_offset.y = fmod(fundo.get_active_material(0).uv1_offset.y + delta * 10, 1.0)
	if not tocando_nota:
		botao.scale.x = lerpf(botao.scale.x, 1.0, delta * 3)
		botao.scale.z = lerpf(botao.scale.z, 1.0, delta * 3)
		
	if Input.is_action_just_pressed(input):
		check_for_hit()
		botao.scale.x = 1.2
		botao.scale.z = 1.2

	if Input.is_action_just_released(input):
		parar_som()

	preencher_buffer()

func criar_nota(semitons : int):
	var nova_nota : Nota = nota_prefab.instantiate()
	nova_nota.semitons = semitons
	nova_nota.position = Vector3(0, 0, -7.5) 
	add_child(nova_nota)
	notas_ativas.append(nova_nota)

func check_for_hit():
	if notas_ativas.size() > 0:
		var mais_perto = 999
		var nota_mais_perto = notas_ativas[0]
		for nota in notas_ativas:
			var dist = abs(nota_mais_perto.position.z - botao.position.z)
			if dist < mais_perto:
				mais_perto = dist
				nota_mais_perto = nota
		
		if mais_perto < area_clique_perdao:
			print("acertou! distancia = ", mais_perto, " / nota = ", nota_mais_perto.semitons)
			notas_ativas.erase(nota_mais_perto)
			nota_mais_perto.queue_free()

			if mais_perto < area_clique_perdao / 2:
				instanciar_texto("Boa!", Color(0, 1, 0, 1))
				nota_tocada.emit(1)
			else:
				instanciar_texto("Perfeito!", Color(1, 0.7, 0, 1))
				nota_tocada.emit(1.1) # bonus

			tocar_som(nota_mais_perto.semitons)
		else:
			print("errou!")
			instanciar_texto("Errou!", Color(1, 0.2, 0.2, 1))

func remover_nota(nota):
	if notas_ativas.has(nota):
		notas_ativas.erase(nota)
		print("perdeu uma nota!")
		print("posicao = " + str(nota.position.z))

func instanciar_texto(texto : String, cor : Color):
	var label = label_prefab.instantiate()
	add_child(label)
	label.position = botao.position
	label.text = texto
	label.modulate = cor

@onready var sintetizador = $Sintetizador
var playback: AudioStreamGeneratorPlayback
var frequencia_base: float = 44100.0
var fase: float = 0.0
var frequencia: float = 0.0
var tocando_nota: bool = false
var amplitude: float = 0.0
var volume_maximo: float = 0.4
var decaimento: float = 20000
var taxa_decaimento: float = 1 - 1 / decaimento

func tocar_som(steps: int):
	frequencia = 261.63 * pow(2.0, steps / 12.0)
	amplitude = volume_maximo
	tocando_nota = true

func parar_som():
	tocando_nota = false
	if playback != null:
		playback.clear_buffer()

func preencher_buffer():
	if playback == null: 
		return

	var incremento = frequencia / frequencia_base
	var frames_available = playback.get_frames_available()
	
	while frames_available > 0:
		var sample = 0.0

		if tocando_nota:
			sample = 1.0 if fase < 0.5 else -1.0
			fase = fmod(fase + incremento, 1.0)

			amplitude *= taxa_decaimento
			if amplitude < 0.0001:
				tocando_nota = false
				amplitude = 0.0

		playback.push_frame(Vector2.ONE * sample * amplitude)
		
		frames_available -= 1
