extends Control

@onready var animation_player = $UI/AnimationPlayer
@onready var fundo_preto = $UI/Black
@onready var player_musica = $UI/Musica
@onready var filtro_daltonismo = $UI/FiltroDaltonismo
@onready var menu = $UI/Menu
@export var cenas : Dictionary[String, PackedScene] = {}
var cena_atual

var caminho_configuracoes = "user://config.json"
var configuracoes : Dictionary = {}

func _ready():
	carregar_configuracoes()
	# carregar_cena("Principal")

func carregar_cena(cena: String) -> void:
	fundo_preto.visible = true
	animation_player.play("fade")
	await animation_player.animation_finished
	
	if cena_atual != cena:
		get_tree().change_scene_to_packed(cenas[cena])
		print("carregando cena \"" + cena+ "\"")

	await get_tree().process_frame 
	
	animation_player.play_backwards("fade")
	await animation_player.animation_finished
	fundo_preto.visible = false

func aplicar_configuracoes(config : Dictionary = configuracoes):
	if menu == null: return
	configuracoes = config

	if configuracoes.has("volume_musica"): player_musica.volume_linear = (configuracoes["volume_musica"] / 100.0) * (configuracoes["volume_master"] / 100.0)
	
	if configuracoes.has("tipo_daltonismo"): match configuracoes["tipo_daltonismo"]:
		"protanopia":
			(filtro_daltonismo.material as ShaderMaterial).set_shader_parameter("filter_mode", 4)
		"deuteranopia":
			(filtro_daltonismo.material as ShaderMaterial).set_shader_parameter("filter_mode", 5)
		"tritanopia":
			(filtro_daltonismo.material as ShaderMaterial).set_shader_parameter("filter_mode", 6)
		"desligado":
			(filtro_daltonismo.material as ShaderMaterial).set_shader_parameter("filter_mode", 0)
	if configuracoes.has("intensidade_daltonismo"): (filtro_daltonismo.material as ShaderMaterial).set_shader_parameter("intensity", configuracoes["intensidade_daltonismo"])

	if configuracoes.has("alto_contraste"): if configuracoes["alto_contraste"]:
		menu.theme = preload("res://themes/alto_contraste.tres")
	else:
		menu.theme = preload("res://themes/default.tres")

	if configuracoes.has("escala_interface"): get_tree().root.content_scale_factor = configuracoes["escala_interface"]

	if configuracoes.has("menu_circular"): 
		menu.menu_circular = configuracoes["menu_circular"]
		($UI/Menu/Fundo.texture as GradientTexture2D).fill = GradientTexture2D.FILL_RADIAL if configuracoes["menu_circular"] else GradientTexture2D.FILL_LINEAR 
	
	var entradas = InputMap.get_actions()
	for entrada in entradas:
		if entrada in configuracoes.keys():
			InputMap.action_erase_events(entrada)
			var novo_evento = InputEventKey.new()
			novo_evento.physical_keycode = configuracoes[entrada]
			InputMap.action_add_event(entrada, novo_evento)

	menu.inicializar_botoes_circulares()

func caractere_tecla(tecla : Key) -> String:
	match tecla:
		KEY_LEFT: return "◀"
		KEY_RIGHT: return "▶"
		KEY_UP: return "▲"
		KEY_DOWN: return "▼"

	return str(OS.get_keycode_string(tecla))

func salvar_configuracoes() -> void:
	var dados_config = {}
	for config in configuracoes.keys():
		dados_config[config] = configuracoes[config]

	var dados_json = JSON.stringify(dados_config, "\t")
	var arquivo = FileAccess.open(caminho_configuracoes, FileAccess.WRITE)
	if arquivo:
		arquivo.store_string(dados_json)
		print("configurações salvas")
		arquivo.close()
	else:
		print("não consegui abrir o arquivo das configurações!!!")
	carregar_configuracoes()

func carregar_configuracoes() -> void:
	var arquivo = FileAccess.open(caminho_configuracoes, FileAccess.READ)
	if arquivo:
		var dados_json = arquivo.get_as_text()
		var dados_config = JSON.parse_string(dados_json)

		if dados_config != null:
			for config in dados_config.keys():
				configuracoes[config] = dados_config[config]

		# print("configurações carregadas:\n" + str(dados_config))
		aplicar_configuracoes(dados_config)
		print("configurações carregadas:\n" + str(configuracoes))
		arquivo.close()
	else:
		print("não consegui abrir o arquivo das configurações!!!")

	$UI/Menu.carregar_configuracoes()
	$UI/Menu.inicializar_botoes_circulares()

func alterar_configuracao(nome : String, valor : Variant):
	configuracoes[nome] = valor
	aplicar_configuracoes()
	$UI/Menu.carregar_configuracoes()
	return
	
