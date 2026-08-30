extends Control

@onready var animation_player = $UI/AnimationPlayer
@onready var black_background = $UI/Black
@onready var music_player = $UI/MusicPlayer
@onready var color_blind_filter = $UI/ColorBlindessFilter
@onready var menu = $UI/Menu
@export var cenas : Dictionary[String, PackedScene] = {}
var current_scene

var path_config = "user://config.json"
var path_save = "user://save.json"

var settings : Dictionary = {}
var game_data : Dictionary = {}

func _ready():
	load_settings()
	load_save()
	# load_scene("Principal")

func load_scene(cena: String) -> void:
	black_background.visible = true
	animation_player.play("fade")
	await animation_player.animation_finished
	
	if current_scene != cena:
		get_tree().change_scene_to_packed(cenas[cena])
		print("carregando cena \"" + cena+ "\"")

	await get_tree().process_frame 
	
	animation_player.play_backwards("fade")
	await animation_player.animation_finished
	black_background.visible = false

func load_map(idx_node : int = game_data["map_position"]) -> void:
	load_scene("map")
	# (get_tree().get_root().get_child(0) as MapController).go_to_node(idx_node)

func apply_settings(config : Dictionary = settings):
	if menu == null: return
	settings = config

	if settings.has("volume_music"): music_player.volume_linear = (settings["volume_music"] / 100.0) * (settings["volume_master"] / 100.0)
	
	if settings.has("colorblind_mode"): 
		match settings["colorblind_mode"]:
			"protanopia":
				(color_blind_filter.material as ShaderMaterial).set_shader_parameter("filter_mode", 4)
			"deuteranopia":
				(color_blind_filter.material as ShaderMaterial).set_shader_parameter("filter_mode", 5)
			"tritanopia":
				(color_blind_filter.material as ShaderMaterial).set_shader_parameter("filter_mode", 6)
			"disabled":
				(color_blind_filter.material as ShaderMaterial).set_shader_parameter("filter_mode", 0)

	if settings.has("colorblind_intensity"): (color_blind_filter.material as ShaderMaterial).set_shader_parameter("intensity", settings["colorblind_intensity"])

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
		print("could not open settings file!!!")

	$UI/Menu.load_settings()
	$UI/Menu.setup_circular_buttons()

func change_setting(name : String, value : Variant):
	settings[name] = value
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

		load_map()
		print("could not open settings file!!!")
		file.close()
	else:
		print("could not open settings file!!!")

func get_game_data(key : String):
	return game_data[key] if game_data[key] != null else null 

func set_game_data(key : String, value):
	game_data[key] = value
