class_name Menu extends NinePatchRect

@export var telas : Dictionary[String, VBoxContainer] = {}

func _ready() -> void:
	fechar_telas()
	$Principal/Jogar.pressed.connect(fechar_telas)
	$Principal/Opções.pressed.connect(abrir_tela.bind("Opções"))
	$Opcoes/Voltar.pressed.connect(abrir_tela.bind("N.I.K."))

func abrir_tela(alvo : String):
	for tela in telas.keys():
		if tela == alvo:
			telas[tela].visible = true
			visible = true
			get_tree().paused = true
			$Titulo.text = tela
		else:
			telas[tela].visible = false

func fechar_telas():
	visible = false
	get_tree().paused = false
	for tela in telas.keys():
		telas[tela].visible = false