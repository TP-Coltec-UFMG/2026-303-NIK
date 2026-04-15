class_name Pista extends Node3D

@onready var fundo = $Fundo
@onready var botao = $Botao
@onready var particulas = $Botao/Particulas
@export var nota_prefab: PackedScene
@export var input: String

var notas_ativas: Array[Nota] = []
var area_clique_z: float = 4.5
@export var area_clique_perdao: float = 0.75

func _ready() -> void:
	sintetizador.play()
	playback = sintetizador.get_stream_playback()

func _process(delta: float) -> void:
	fundo.get_active_material(0).uv1_offset.y = fmod(fundo.get_active_material(0).uv1_offset.y - delta * 10, 1.0)
	botao.scale.x = lerpf(botao.scale.x, 1.0, delta * 3)
	botao.scale.z = lerpf(botao.scale.z, 1.0, delta * 3)
		
	if Input.is_action_just_pressed(input):
		check_for_hit()
		botao.scale.x = 1.2
		botao.scale.z = 1.2

	if Input.is_action_just_released(input):
		parar_som()

	if tocando_nota:
		fill_audio_buffer()

func criar_nota(meio_passos : int):
	var nova_nota : Nota = nota_prefab.instantiate()
	nova_nota.meio_passos = meio_passos
	nova_nota.position = Vector3(0, 0, -20.0) 
	add_child(nova_nota)
	notas_ativas.append(nova_nota)

func check_for_hit():
	if notas_ativas.size() > 0:
		var mais_perto = 999
		var nota_mais_perto = notas_ativas[0]
		for nota in notas_ativas:
			var dist = abs(nota_mais_perto.position.z - area_clique_z)
			if dist < mais_perto:
				mais_perto = dist
				nota_mais_perto = nota
		
		if mais_perto < area_clique_perdao:
			print("acertou! distancia = ", mais_perto, " / nota = ", nota_mais_perto.meio_passos)
			notas_ativas.erase(nota_mais_perto)
			nota_mais_perto.queue_free()

			tocar_som(nota_mais_perto.meio_passos)
			
			particulas.emitting = true
			particulas.restart()
		else:
			print("errou!")

func remover_nota(nota):
	if notas_ativas.has(nota):
		notas_ativas.erase(nota)
		print("perdeu uma nota!")
		print("posicao = " + str(nota.position.z))

@onready var sintetizador = $Sintetizador
var playback: AudioStreamGeneratorPlayback
var frequencia_base: float = 44100.0
var fase: float = 0.0
var frequencia: float = 0.0
var tocando_nota: bool = false

func tocar_som(steps: int):
	frequencia = 261.63 * pow(2.0, steps / 12.0)
	tocando_nota = true

func parar_som():
	tocando_nota = false

func fill_audio_buffer():
	var incremento = frequencia / frequencia_base
	var frames_available = playback.get_frames_available()
	
	while frames_available > 0:
		var sample = 1.0 if fase < 0.5 else -1.0
		
		playback.push_frame(Vector2.ONE * sample * 0.2)
		
		fase = fmod(fase + incremento, 1.0)
		frames_available -= 1
