class_name BotaoToggle extends Button

var valor : int = 0
@export var id : String = "id"
@export var valores : Array[ValorToggle] = [] #73c0ff #ff7373
@export var nome : String = "Toggle"
@onready var label : RichTextLabel = $Label

func _ready() -> void:
	if valores and valores:
		pass
	else: print_debug("botão toggle sem valores")

func _process(delta: float) -> void:
	label.text = "[color=" + ("b5e3ff]" if has_focus() else "ffffff]") + nome + ": [/color][color=" + valores[valor].cor.to_html() + "]" + valores[valor].nome + "[/color]"

func _pressed() -> void:
	valor = (valor + 1) % maxi(1, valores.size())
	# atualizar_visual()
