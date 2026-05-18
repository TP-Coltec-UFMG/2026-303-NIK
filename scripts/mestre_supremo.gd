extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var fundo_preto = $Black
@onready var player_musica = $Musica
@onready var filtro_daltonismo = $FiltroDaltonismo
@onready var menu = $UI/Menu

var configuracoes = {}

func _ready():
	menu.carregar_configuracoes()

func carregar_cena(cena: PackedScene) -> void:
	fundo_preto.visible = true
	animation_player.play("fade")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_packed(cena)
	
	await get_tree().process_frame 
	
	animation_player.play_backwards("fade")
	await animation_player.animation_finished
	fundo_preto.visible = false

func aplicar_configuracoes(config : Dictionary):
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

	if configuracoes.has("menu_circular"): menu.menu_circular = configuracoes["menu_circular"]
	
	var entradas = InputMap.get_actions()
	for entrada in entradas:
		if entrada in configuracoes.keys():
			InputMap.action_erase_events(entrada)
			var novo_evento = InputEventKey.new()
			novo_evento.physical_keycode = configuracoes[entrada]
			InputMap.action_add_event(entrada, novo_evento)

	menu.inicializar_botoes_circulares()
