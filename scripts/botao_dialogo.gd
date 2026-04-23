class_name BotaoDialogo extends Button

func configurar(texto : String, tipo : ControleDialogo.Escolhas.TIPO_ESCOLHA):
	text = texto
	match tipo:
		ControleDialogo.Escolhas.TIPO_ESCOLHA.INVESTIGACAO: 
			add_theme_color_override("font_color", Color(1, 1, 1))
			add_theme_color_override("font_hover_color", Color(.9, .95, 1))
		ControleDialogo.Escolhas.TIPO_ESCOLHA.SAIR: 
			add_theme_color_override("font_color", Color(1, .95, .8))
			add_theme_color_override("font_hover_color", Color(1, .9, .6))
		_: 
			add_theme_color_override("font_color", Color.RED)
			add_theme_color_override("font_hover_color", Color.DARK_RED)
