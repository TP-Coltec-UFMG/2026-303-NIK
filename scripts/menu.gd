class_name Menu extends NinePatchRect

@export var telas : Dictionary[String, VBoxContainer] = {}

var caminho_configuracoes = "user://config.json"

@export var configuracoes : Array = []

func _ready() -> void:
	fechar_telas()
	$Principal/Jogar.pressed.connect(fechar_telas)
	$Principal/Opções.pressed.connect(abrir_tela.bind("Opções"))
	$Opcoes/Voltar.pressed.connect(salvar_configuracoes)

	for configuracao in $Opcoes.get_children():
		if configuracao.name != "Voltar":
			configuracoes.append(configuracao)

	carregar_configuracoes()

func abrir_tela(alvo : String):
	print("carregando tela \"" + alvo + "\"")
	var tela_existe = false
	for tela in telas.keys():
		if tela == alvo:
			telas[tela].get_child(0).grab_focus()
			tela_existe = true
			telas[tela].visible = true
			visible = true
			get_tree().paused = true
			$Titulo.text = tela
		else:
			telas[tela].visible = false
	
	if not tela_existe:
		print("tela \"" + alvo + "\" não existe!!!")

func fechar_telas():
	visible = false
	get_tree().paused = false
	for tela in telas.keys():
		telas[tela].visible = false

func salvar_configuracoes() -> void:
	abrir_tela("Menu")

	var dados_config = {}
	for config in configuracoes:
		if config is BotaoToggle:
			var nome = config.id
			var dado = config.valor
			dados_config[nome] = dado

	var dados_json = JSON.stringify(dados_config, "\t")
	var arquivo = FileAccess.open(caminho_configuracoes, FileAccess.WRITE)
	if arquivo:
		arquivo.store_string(dados_json)
		print("configurações salvas")
		arquivo.close()
	else:
		print("não consegui abrir o arquivo das configurações!!!")
	carregar_configuracoes()

func carregar_configuracoes() -> void:
	var arquivo = FileAccess.open(caminho_configuracoes, FileAccess.READ)
	if arquivo:
		var dados_json = arquivo.get_as_text()
		var dados_config = JSON.parse_string(dados_json)

		if dados_config != null:
			for config in configuracoes:
				if config is BotaoToggle:
					if config.id in dados_config:
						config.valor = dados_config[config.id]
					else: print("configuração \"" + config.id + "\" não está no arquivo: valor padrão será utilizado")
				if config.id == "alto-contraste":
					if config.valor == 0:
						print("ativando o modo alto-contraste")
						theme = preload("res://themes/alto_contraste.tres")
					else:
						print("desativando o modo alto-contraste")
						theme = preload("res://themes/default.tres")
					atualizar_visual_botoes()
				if config.id == "escala-interface":
					if config.valor == 0:
						get_tree().root.content_scale_factor = 1.0
					elif config.valor == 1:
						get_tree().root.content_scale_factor = 1.5
					elif config.valor == 2:
						get_tree().root.content_scale_factor = 0.5

		print("configurações carregadas")
		arquivo.close()
	else:
		print("não consegui abrir o arquivo das configurações!!!")

func atualizar_visual_botoes():
	for filho in get_children(true):
		if filho is BotaoToggle:
			filho.atualizar_visual()