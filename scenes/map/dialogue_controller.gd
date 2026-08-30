extends CanvasLayer

const dialogue_files = "res://dialogues.json"

@onready var dialogue_box = $DialogueBox
@onready var dialogue_text = $DialogueBox/DialogueText
var dialogues = {}

var active_dialogue : DialogueString = null
var current_line = 0;

func _ready() -> void:
	read_dialogue_file()
	
	dialogue_box.hide()
	
	if active_dialogue != null:
		end_dialogue()

func start_dialogue(dialogue_id : String):
	get_tree().paused = true
	dialogue_box.show()
	active_dialogue = dialogues[dialogue_id]
	current_line = 0
	next_line(0)

func next_line(idx : int = current_line + 1):
	current_line = idx
	if current_line >= active_dialogue.lines.size():
		end_dialogue()
		return

	dialogue_text.text = "[font_size=32][color=#60bbff]" + active_dialogue.lines[current_line].name + "\n[font_size=24][color=white]" + active_dialogue.lines[current_line].text

func end_dialogue():
	get_tree().paused = false
	dialogue_box.hide()
	var dialogue_redirect = active_dialogue.redirect
	active_dialogue = null
	# redirecionar para a cena
	if dialogue_redirect:
		GameManager.load_scene(dialogue_redirect)


func _unhandled_input(event: InputEvent) -> void:
	if active_dialogue != null:
		if event.is_action_pressed("ui_accept"):
			next_line();

func read_dialogue_file():
	var file = FileAccess.open(dialogue_files, FileAccess.READ)
	if file:
		var json = file.get_as_text()
		var data = JSON.parse_string(json)

		if data != null:
			dialogues = {}
			for dialogue in data:
				var lines : Array[DialogueLine] = []
				for line in dialogue.lines:
					lines.append(DialogueLine.new(line.name, line.text))
				
				dialogues[dialogue.id] = DialogueString.new(dialogue.id, lines, dialogue.redirect)

		print("diálogos carregados!\n")
		file.close()
	else:
		printerr("não consegui abrir o file dos diálogos!!!")

class DialogueString:
	var id : String
	var lines : Array[DialogueLine]
	var redirect : String

	func _init(_id : String, _lines : Array[DialogueLine], _redirect : String):
		id = _id
		lines = _lines
		redirect = _redirect

class DialogueLine:
	var name : String
	var text : String

	func _init(_name : String, _text : String):
		name = _name
		text = _text
