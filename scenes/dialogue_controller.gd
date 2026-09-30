extends CanvasLayer

# Tempo entre letras do texto do diálogo
const TEXT_CHARACTER_INTERVAL = 0.03
# Tempo entre pontuação (, . ! ? : ;), para dar uma pausa na fala
const PUNCTUATION_INTERVAL = 0.2
const PUNCTUATION_CHARS = [",", ".", "!", "?", ":", ";"]

# Tempo da animação da caixa de diálogo subindo/descendo
const DIALOGUE_BOX_ANIMATION_TIME = 1.2

# Amplitude da animação de bobbing da caixa
const DIALOGUE_BOX_BOBBING_AMPLITUDE = 1.0
const DIALOGUE_BOX_BOBBING_BASE_SPEED = 1.4

const dialogue_files = "res://dialogues.json"

@onready var dialogue_box = $DialogueBox
@onready var dialogue_text = $DialogueBox/DialogueText
@onready var dialogue_head : TextureRect = $DialogueBox/Head
var dialogues = {}
var characters = {}

var active_dialogue : DialogueString = null
var current_line = 0;

signal dialogue_finished

signal please_move_nikole(node_idx: String, follower: String, target_position: Vector2)
signal nikole_moved

enum RedirectType { NONE, DIALOGUE, NODE, SCENE, NODE_EDIT }

func _ready() -> void:
	read_dialogue_file()
	
	dialogue_box.hide()
	
	if active_dialogue != null:
		end_dialogue()

	dialogue_box.offset_transform_position_ratio.y = 1.4 # deixa a caixa de diálogo fora da tela no começo
	
	await get_tree().process_frame
	get_parent().move_child(self, -1) # mexe ele pra baixo, aí ele pega input antes do GameManager (impede de pausar o jogo enquanto está em dialogo)

func start_dialogue(dialogue_id : String, force : bool= false):
	if not GameManager.can_start_dialogue and not force: return

	# get_tree().paused = true
	dialogue_box.show()
	if dialogues[dialogue_id].condition:
		if GameManager.get_game_data(dialogues[dialogue_id].condition.data) == dialogues[dialogue_id].condition.value:
			active_dialogue = dialogues[dialogue_id]
		else: 
			active_dialogue = dialogues[dialogues[dialogue_id].condition.elseDialogue]
	else: 
		active_dialogue = dialogues[dialogue_id]
		
	current_line = 0
	next_line(0)
	animate_dialogue_box(1)

func next_line(idx : int = -1):
	if idx != -1:
		current_line = idx
	else:
		current_line += 1

		
	if current_line >= active_dialogue.lines.size():
		end_dialogue()
		return

	var character = active_dialogue.lines[current_line].name
	var line = active_dialogue.lines[current_line].text	

	# Deixa apenas o nome visível
	dialogue_text.visible_characters = active_dialogue.lines[current_line].name.length()

	if not character.is_empty():
		dialogue_text.text = "[font_size=36][color=" + characters[character] + "]" + character + "\n[font_size=28][color=black]" + line
		dialogue_head.texture = load("res://sprites/map/npcs/heads/" + character + ".png")
	else:
		dialogue_head.texture = null
		dialogue_text.text = "[font_size=36] \n[font_size=28][color=black]" + line
		
func end_dialogue():
	GameManager.can_start_dialogue = false

	var current_redirects = active_dialogue.redirects
	active_dialogue = null

	await animate_dialogue_box(-1)
	dialogue_box.hide()

	dialogue_text.visible_characters = 0
	
	emit_signal("dialogue_finished")
	
	if current_redirects.size() > 0:
		execute_redirects(current_redirects)
	GameManager.save_game()

	var is_changing_scene = false
	for action in current_redirects:
		if action.type == RedirectType.SCENE:
			is_changing_scene = true
			break

	if not is_changing_scene: # se nao tiver trocando de cena ele reativa normal, e se tiver trocando ele vai reativar sozinho quando carregar a cena nova
		await get_tree().create_timer(0.5).timeout
		GameManager.can_start_dialogue = true

# Retorna se a animação de caracteres já terminou
func has_character_animation_finished() -> bool:
	var parsed_text = dialogue_text.get_parsed_text() # retira as tags
	return dialogue_text.visible_characters >= parsed_text.length()

var _char_animation_time : float = 0.0 # tempo até a aparição do próximo caractere
var _box_animation_i : float = 0 # contador de animação da caixa de diálogo
func _process(delta: float) -> void:
	_char_animation_time -= delta
	_box_animation_i += delta

	# Se há diálogo
	if active_dialogue:
		
		# Animação de bobbing (balançando)
		var x : float = sin(_box_animation_i * DIALOGUE_BOX_BOBBING_BASE_SPEED - 0.67) * DIALOGUE_BOX_BOBBING_AMPLITUDE
		var y : float = cos(_box_animation_i * (DIALOGUE_BOX_BOBBING_BASE_SPEED + 0.6) + 0.3) * DIALOGUE_BOX_BOBBING_AMPLITUDE
		dialogue_box.offset_transform_position = Vector2(x, y)

		# Animação de digitar
		var parsed_text = dialogue_text.get_parsed_text() # retira as tags
		if (not has_character_animation_finished()) and _char_animation_time < 0: # se a animação ainda não terminou e já pode colocar o próximo caractere
			dialogue_text.visible_characters += 1 # deixa mais um caractere visível
			var text_char : String = parsed_text[dialogue_text.visible_characters - 1]
			# Define o tempo até o próximo caractere em função do tipo (se for
			# pontuação, vai demorar um tempo diferente do normal)
			_char_animation_time = PUNCTUATION_INTERVAL \
								if text_char and (text_char in PUNCTUATION_CHARS) \
								else TEXT_CHARACTER_INTERVAL

# Anima a caixa de diálogo aparecendo ou sumindo (dir = 1 para aparecer, dir = -1 para sumir)
func animate_dialogue_box(dir : int): 
	var tween : Tween = create_tween()
	var pos_ratio_y : float = 0.0 if dir == 1 else 1.4
	var tween_ease : Tween.EaseType = Tween.EASE_OUT

	tween \
		.tween_property(dialogue_box, "offset_transform_position_ratio:y", pos_ratio_y, DIALOGUE_BOX_ANIMATION_TIME if dir == 1 else DIALOGUE_BOX_ANIMATION_TIME / 3.0) \
		.set_trans(Tween.TRANS_ELASTIC if dir == 1 else Tween.TRANS_EXPO) \
		.set_ease(tween_ease)

	# Espera o tween acabar
	await tween.finished

func execute_redirects(redirects_queue: Array[DialogueRedirect]):
	if redirects_queue.is_empty():
		get_tree().paused = false
		return
		
	for action in redirects_queue:
		match action.type:
			RedirectType.SCENE:
				get_tree().paused = false
				GameManager.load_scene(action.target)
				print("loading scene " + action.target + "\"")
				return # carrega a cena e finaliza (carregar a cena tem que ser o último sempre)
				
			RedirectType.DIALOGUE:
				start_dialogue(action.target, true)
				print("starting dialogue " + action.target + "\"")
				await self.dialogue_finished # espera o diálogo acabar
				
			RedirectType.NODE:
				get_tree().paused = false
				emit_signal("please_move_nikole", int(action.target), action.follower, action.follower_target)
				print("moving to node \"" + action.target + "\"")
				await self.nikole_moved # espera a nikole andar
				
			RedirectType.NODE_EDIT:
				get_tree().paused = false
				var nodes_data : Dictionary = GameManager.get_game_data("nodes")
				print("edited node data \"" + action.target + "\": \"" + nodes_data[action.target] + "\" -> \"" + action.target + "\": \"" + action.data + "\"")
				nodes_data[action.target] = action.data
				GameManager.set_game_data("nodes", nodes_data)

	if active_dialogue == null:
		get_tree().paused = false

func move_to_node_finished():
	emit_signal("nikole_moved")

func _input(event: InputEvent) -> void:
	if active_dialogue != null:
		if event.is_action_pressed("interact"):
			if has_character_animation_finished(): # Se a animação já terminou, pula pra próxima fala
				next_line()
			else: # Se a animação não terminou, mostra a fala inteira
				dialogue_text.visible_characters = dialogue_text.get_parsed_text().length()
		get_viewport().set_input_as_handled() # consome todos os inputs enquanto estiver no diálogo pq ai da pra nao pausar o jogo ;)

func read_dialogue_file():
	var file = FileAccess.open(dialogue_files, FileAccess.READ)
	if file:
		var json = file.get_as_text()
		var data = JSON.parse_string(json)

		if data != null:
			dialogues = {}
			for dialogue in data.dialogues:
				var condition = DialogueCondition.new(dialogue.condition.data, dialogue.condition.value == "true", dialogue.condition.else) if dialogue.get("condition") else null
				var lines : Array[DialogueLine] = []
				for line in dialogue.lines:
					lines.append(DialogueLine.new(line.name, line.text))

				var redirects : Array[DialogueRedirect] = []
				if dialogue.has("redirect"):
					var redirect_data = dialogue["redirect"]
					if typeof(redirect_data) == TYPE_ARRAY: # se no redirect for um array
						for r in redirect_data:
							redirects.append(DialogueRedirect.new(str(r)))
					elif typeof(redirect_data) == TYPE_STRING and redirect_data != "": # se no redirect for um só
						redirects.append(DialogueRedirect.new(redirect_data))

				dialogues[dialogue.id] = DialogueString.new(dialogue.id, condition, lines, redirects)
			for character in data.character_colors.keys():
				characters[character] = data.character_colors[character]
		print("diálogos carregados!\n")
		file.close()
	else:
		printerr("não consegui abrir o file dos diálogos!!!")

class DialogueRedirect:
	var type : RedirectType = RedirectType.NONE
	var target : String = ""
	var data : String = ""
	var follower : String = ""
	var follower_target : Vector2 = Vector2()

	func _init(redirect_string: String): # parsing do comando de redirect
		if ":" in redirect_string:
			var parts = redirect_string.split(":", true, 0) 
			target = parts[1]
			
			match parts[0]:
				"dialogue": type = RedirectType.DIALOGUE
				"node": 
					type = RedirectType.NODE
					if parts.size() > 2:
						follower = parts[2]
						if not follower.is_empty():
							follower_target.x = float(parts[3])
							follower_target.y = float(parts[4])
				"scene": type = RedirectType.SCENE
				"node_edit": 
					type = RedirectType.NODE_EDIT
					data = parts[2]
		else:
			print("fred meteu um redirect zoado")

class DialogueString:
	var id : String
	var condition : DialogueCondition
	var lines : Array[DialogueLine]
	var redirects : Array[DialogueRedirect]

	func _init(_id : String, _condition : DialogueCondition, _lines : Array[DialogueLine], _redirects : Array[DialogueRedirect]):
		id = _id
		condition = _condition
		lines = _lines
		redirects = _redirects

class DialogueCondition:
	var data : String
	var value : bool
	var elseDialogue : String
	
	func _init(_data : String, _value : bool, _elseData : String):
		data = _data
		value = _value
		elseDialogue = _elseData

class DialogueLine:
	var name : String
	var text : String

	func _init(_name : String, _text : String):
		name = _name
		text = _text
