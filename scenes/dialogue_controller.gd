extends CanvasLayer

const dialogue_files = "res://dialogues.json"

@onready var dialogue_box = $DialogueBox
@onready var dialogue_text = $DialogueBox/DialogueText
var dialogues = {}

var active_dialogue : DialogueString = null
var current_line = 0;

signal dialogue_finished

signal please_mose_nikole(node_idx: String)
signal nikole_moved

enum RedirectType { NONE, DIALOGUE, NODE, SCENE }

func _ready() -> void:
	read_dialogue_file()
	
	dialogue_box.hide()
	
	if active_dialogue != null:
		end_dialogue()

func start_dialogue(dialogue_id : String):
	get_tree().paused = true
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

func next_line(idx : int = current_line + 1):
	current_line = idx
	if current_line >= active_dialogue.lines.size():
		end_dialogue()
		return

	dialogue_text.text = "[font_size=36][color=#60bbff]" + active_dialogue.lines[current_line].name + "\n[font_size=28][color=black]" + active_dialogue.lines[current_line].text

func end_dialogue():
	dialogue_box.hide()
	
	var current_redirects = active_dialogue.redirects
	active_dialogue = null
	
	emit_signal("dialogue_finished")
	
	execute_redirects(current_redirects)

func execute_redirects(redirects_queue: Array[DialogueRedirect]):
	if redirects_queue.is_empty():
		get_tree().paused = false
		return
		
	for action in redirects_queue:
		match action.type:
			RedirectType.SCENE:
				get_tree().paused = false
				GameManager.load_scene(action.target)
				return # carrega a cena e finaliza (carregar a cena tem que ser o último sempre)
				
			RedirectType.DIALOGUE:
				start_dialogue(action.target)
				await self.dialogue_finished # espera o diálogo acabar
				
			RedirectType.NODE:
				get_tree().paused = false
				emit_signal("please_mose_nikole", action.target)
				await self.nikole_moved # espera a nikole andar

	if active_dialogue == null:
		get_tree().paused = false

func move_to_node_finished():
	emit_signal("nikole_moved")

func _unhandled_input(event: InputEvent) -> void:
	if active_dialogue != null:
		if event.is_action_pressed("ui_accept"):
			next_line()

func read_dialogue_file():
	var file = FileAccess.open(dialogue_files, FileAccess.READ)
	if file:
		var json = file.get_as_text()
		var data = JSON.parse_string(json)

		if data != null:
			dialogues = {}
			for dialogue in data:
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

		print("diálogos carregados!\n")
		file.close()
	else:
		printerr("não consegui abrir o file dos diálogos!!!")

class DialogueRedirect:
	var type : RedirectType = RedirectType.NONE
	var target : String = ""

	func _init(redirect_string: String): # parsing do comando de redirect
		if ":" in redirect_string:
			var parts = redirect_string.split(":", true, 1) 
			target = parts[1]
			
			match parts[0]:
				"dialogue": type = RedirectType.DIALOGUE
				"node": type = RedirectType.NODE
				"scene": type = RedirectType.SCENE
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