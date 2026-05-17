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

	player_musica.volume_linear = (configuracoes["volume_musica"] / 100.0) * (configuracoes["volume_master"] / 100.0)
	
	match configuracoes["tipo_daltonismo"]:
		"protanopia":
			(filtro_daltonismo.material as ShaderMaterial).set_shader_parameter("filter_mode", 4)
		"deuteranopia":
			(filtro_daltonismo.material as ShaderMaterial).set_shader_parameter("filter_mode", 5)
		"tritanopia":
			(filtro_daltonismo.material as ShaderMaterial).set_shader_parameter("filter_mode", 6)
		"desligado":
			(filtro_daltonismo.material as ShaderMaterial).set_shader_parameter("filter_mode", 0)
	(filtro_daltonismo.material as ShaderMaterial).set_shader_parameter("intensity", configuracoes["intensidade_daltonismo"])

	if configuracoes["alto_contraste"]:
		menu.theme = preload("res://themes/alto_contraste.tres")
	else:
		menu.theme = preload("res://themes/default.tres")

	get_tree().root.content_scale_factor = configuracoes["escala_interface"]
	
