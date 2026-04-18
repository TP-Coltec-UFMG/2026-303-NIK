class_name BotaoDialogo extends TextureButton

@export var investigacao_icone : Texture2D
@export var sair_icone : Texture2D
@onready var label = $Label
@onready var icone = $Icone

func configurar(texto : String, tipo : ControleDialogo.Escolhas.TIPO_ESCOLHA):
	label = $Label
	icone = $Icone
	label.text = texto
	match tipo:
		ControleDialogo.Escolhas.TIPO_ESCOLHA.INVESTIGACAO: icone.texture = investigacao_icone
		ControleDialogo.Escolhas.TIPO_ESCOLHA.SAIR: icone.texture = sair_icone
		_: icone.texture = null
