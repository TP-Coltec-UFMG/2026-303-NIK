extends Control

# Duração da transição de músicas (em segundos)
const MUSIC_TRANSITION_DURATION : float = 2.0
# Volume normal do Music Player (em dB)
const MUSIC_VOLUME : float = 0 # 0db = volume padrão do arquivo

@onready var animation_player = $UI/AnimationPlayer
@onready var black_background = $UI/Black
@onready var music_player = $UI/MusicPlayer
@onready var color_blind_filter = $UI/ColorBlindessFilter
@onready var menu = $UI/Menu
@export var cenas : Dictionary[String, PackedScene] = {}
var current_scene
var current_music : String

var path_config = "user://config.json"
var path_save = "user://save.json"

var settings : Dictionary = {}
var game_data : Dictionary = {}
var musics : Dictionary = {}

func _ready():
	load_settings()
	load_save()
	load_musics()
	play_music("neighborhood")
	# load_scene("Principal")

func load_scene(cena: String) -> void:
	black_background.visible = true
	animation_player.play("fade")
	await animation_player.animation_finished
	
	if current_scene != cena:
		get_tree().change_scene_to_packed(cenas[cena])
		print("carregando cena \"" + cena+ "\"")
		save_game()

	await get_tree().process_frame 
	
	animation_player.play_backwards("fade")
	await animation_player.animation_finished
	black_background.visible = false

func load_map(idx_node : int = game_data["map_position"]) -> void:
	play_music("neighborhood")
	load_scene("map")

	# (get_tree().get_root().get_child(0) as MapController).go_to_node(idx_node)

func apply_settings(config : Dictionary = settings):
	if menu == null: return
	settings = config

	if settings.has("volume_music") and settings.has("volume_master"):
		music_player.volume_linear = (settings["volume_music"] / 100.0) * (settings["volume_master"] / 100.0)
	
	if settings.has("colorblindness_mode"): 
		match settings["colorblindness_mode"]:
			"protanopia":
				(color_blind_filter.material as ShaderMaterial).set_shader_parameter("filter_mode", 4)
			"deuteranopia":
				(color_blind_filter.material as ShaderMaterial).set_shader_parameter("filter_mode", 5)
			"tritanopia":
				(color_blind_filter.material as ShaderMaterial).set_shader_parameter("filter_mode", 6)
			"desligado":
				(color_blind_filter.material as ShaderMaterial).set_shader_parameter("filter_mode", 0)

	if settings.has("colorblindness_mode"):
		match settings["colorblindness_mode"]:
			"protanopia":
				(color_blind_filter.material as ShaderMaterial).set_shader_parameter("filter_mode", 4)
			"deuteranopia":
				(color_blind_filter.material as ShaderMaterial).set_shader_parameter("filter_mode", 5)
			"tritanopia":
				(color_blind_filter.material as ShaderMaterial).set_shader_parameter("filter_mode", 6)
			"disabled":
				(color_blind_filter.material as ShaderMaterial).set_shader_parameter("filter_mode", 0)

	if settings.has("colorblindness_intensity"):
		(color_blind_filter.material as ShaderMaterial).set_shader_parameter("intensity", settings["colorblindness_intensity"])

	if settings.has("font_family"): if settings["font_family"]:
		menu.theme = preload("res://themes/easy_read.tres")
		DialogueController.dialogue_box.theme = preload("res://themes/easy_read.tres")
	else:
		menu.theme = preload("res://themes/default.tres")
		DialogueController.dialogue_box.theme = preload("res://themes/default.tres")

	if settings.has("ui_scale"): get_tree().root.content_scale_factor = settings["ui_scale"]

	if settings.has("circular_menu"): 
		menu.circular_menu = settings["circular_menu"]
		($UI/Menu/BackGround.texture as GradientTexture2D).fill = GradientTexture2D.FILL_RADIAL if settings["circular_menu"] else GradientTexture2D.FILL_LINEAR 
	
	var inputs = InputMap.get_actions()
	for input in inputs:
		if input in settings.keys():
			InputMap.action_erase_events(input)
			var new_event = InputEventKey.new()
			new_event.physical_keycode = settings[input]
			InputMap.action_add_event(input, new_event)
			# Atualiza no menu de dicas de controles
			menu.update_controls_tip(input, settings[input])

	menu.setup_circular_buttons()

func char_from_key(key : Key) -> String:
	match key:
		KEY_LEFT: return "◀"
		KEY_RIGHT: return "▶"
		KEY_UP: return "▲"
		KEY_DOWN: return "▼"

	return str(OS.get_keycode_string(key))

func get_key_from_action(action : String) -> String:
	var eventos = InputMap.action_get_events(action)

	for evento in eventos:
		if evento is InputEventKey:
			return char_from_key(evento.physical_keycode)
	return "error"

func save_settings() -> void:
	var config_data = {}
	for config in settings.keys():
		config_data[config] = settings[config]

	var json = JSON.stringify(config_data, "\t")
	var file = FileAccess.open(path_config, FileAccess.WRITE)
	if file:
		file.store_string(json)
		print("settings saved!")
		file.close()
	else:
		print("could not open settings file!!!")
	load_settings()

func create_default_settings() -> void:
	settings["circular_menu"] = true
	settings["colorblindness_intensity"] = 0.0
	settings["colorblindness_mode"] = "desligado"
	settings["font_family"] = false
	settings["interact"] = 69.0
	settings["move_down"] = 83.0
	settings["move_left"] = 65.0
	settings["move_right"] = 68.0
	settings["move_up"] = 87.0
	settings["ui_scale"] = 1.0
	settings["volume_master"] = 50.0
	settings["volume_music"] = 50.0
	settings["volume_voices"] = 50.0
	save_settings()

func load_settings() -> void:
	var file = FileAccess.open(path_config, FileAccess.READ)
	if file:
		var json = file.get_as_text()
		var config_data = JSON.parse_string(json)

		if config_data != null:
			for config in config_data.keys():
				settings[config] = config_data[config]

		# print("configurações carregadas:\n" + str(config_data))
		apply_settings(config_data)
		print("could not open settings file!!!")
		file.close()
	else:
		create_default_settings()
		print("could not open settings file!!!")

	$UI/Menu.load_settings()
	$UI/Menu.setup_circular_buttons()

func change_setting(key : String, value : Variant):
	settings[key] = value
	apply_settings()
	$UI/Menu.load_settings()
	return
	
func save_game() -> void:
	var save_data = {}
	for save in game_data.keys():
		save_data[save] = game_data[save]

	var json = JSON.stringify(save_data, "\t")
	var file = FileAccess.open(path_save, FileAccess.WRITE)
	if file:
		file.store_string(json)
		print("game saved!")
		file.close()
	else:
		print("could not open save file!!!")
	# load_save()

func load_save() -> void:
	var file = FileAccess.open(path_save, FileAccess.READ)
	if file:
		var json = file.get_as_text()
		var save_data = JSON.parse_string(json)

		if save_data != null:
			for save in save_data.keys():
				game_data[save] = save_data[save]

		# load_map()
		print("could not open settings file!!!")
		file.close()
	else:
		create_blank_save()
		print("could not open settings file!!!")

func get_game_data(key : String):
	return game_data[key] if game_data[key] != null else null 

func set_game_data(key : String, value):
	game_data[key] = value

func create_blank_save():
	set_game_data("map_position", 0)

	set_game_data("luzia_minigame_completed", false)
	set_game_data("joao_minigame_completed", false)
	set_game_data("caio_minigame_completed", false)
	set_game_data("alex_minigame_completed", false)

# Carrega as músicas, para evitar que elas só sejam
# carregadas no momento que forem usadas
func load_musics():
	const musics_folder_path : String = "res://audio/musics"
	# Abre a pasta das músicas
	var dir : DirAccess = DirAccess.open(musics_folder_path) # fopen pros íntimos
	if not dir: 
		print("Nao foi possivel carregar as musicas!")
		return

	# Se chegou até aqui, conseguiu abrir a pasta das músicas
	dir.list_dir_begin()

	# Obtém o próximo arquivo até acabar os arquivos
	var file_name : String = dir.get_next()
	while file_name != "":
		if not file_name.begins_with(".") and not file_name.ends_with(".import"):
			# Se for um arquivo (não for uma pasta), adiciona ao dicionário de músicas
			if not dir.current_is_dir():
				var formatted_file_name = file_name.get_slice(".", 0)
				musics[formatted_file_name] = load(musics_folder_path.path_join(file_name))
				
		file_name = dir.get_next()
	dir.list_dir_end() # fclose() pros íntimos

var _music_transition_id : int = 0 # transição
var _current_music_tween : Tween # tween do fade in / fade out
# Toca a música com o nome dado, fazendo uma transição suave
# entre a música que está tocando e a música dada
func play_music(song_name : String):
	# Se for a mesma música, não recomeça
	if current_music == song_name: return

	_music_transition_id += 1
	var transition_id := _music_transition_id
	var target_volume_db := MUSIC_VOLUME
	if settings.has("volume_music") and settings.has("volume_master"):
		var target_volume_linear = (settings["volume_music"] / 100.0) * (settings["volume_master"] / 100.0)
		target_volume_db = linear_to_db(maxf(target_volume_linear, 0.0001))

	# Se já tiver transição, para ela
	if _current_music_tween and _current_music_tween.is_valid():
		_current_music_tween.kill()

	# Para a música atual linearmente (se houver)
	if current_music and music_player.playing:
		_current_music_tween = create_tween()
		_current_music_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		_current_music_tween.tween_property(music_player, 'volume_db', -80, MUSIC_TRANSITION_DURATION / 2)
		await _current_music_tween.finished
		if transition_id != _music_transition_id: return
	
	var next_music = musics.get(song_name)
	if next_music == null:
		push_error("Musica nao encontrada: " + song_name)
		song_name = "neighborhood"
		next_music = musics.get(song_name)

	current_music = song_name

	# Para e troca a música
	music_player.stop()
	music_player.stream = next_music

	# Inicia a música e toca um fade in
	music_player.volume_db = -80
	music_player.play()
	_current_music_tween = create_tween()
	_current_music_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_current_music_tween.tween_property(music_player, 'volume_db', target_volume_db, MUSIC_TRANSITION_DURATION / 2)
	await _current_music_tween.finished
	if transition_id == _music_transition_id:
		_current_music_tween = null
