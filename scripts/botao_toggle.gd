class_name BotaoToggle extends Button

var valor : int = 0:
	set(novo_valor):
		valor = novo_valor
		atualizar_visual()
@export var id : String = "id"
@export var valores : Array[ValorToggle] = []
@export var nome : String = "Toggle"
@onready var label : RichTextLabel = $Label

func _ready() -> void:
	focus_entered.connect(atualizar_visual)
	focus_exited.connect(atualizar_visual)
	
	mouse_entered.connect(atualizar_visual)
	mouse_exited.connect(atualizar_visual)

	if valores and valores.size() > 0:
		pass
	else: print_debug("botão toggle sem valores")

	atualizar_visual()

func atualizar_visual() -> void:
	label.text = "[color=" + (get_theme_color("font_focus_color", "Button").to_html() if has_focus() or is_hovered() else get_theme_color("font_color", "Button").to_html()) + "]" + nome + ": [/color][color=" + valores[valor].cor.to_html() + "]" + valores[valor].nome + "[/color]"
	# label.reset_size()
	custom_minimum_size.y = label.get_minimum_size().y

func _pressed() -> void:
	valor = (valor + 1) % maxi(1, valores.size())
