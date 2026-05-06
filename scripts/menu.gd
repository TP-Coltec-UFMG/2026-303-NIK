class_name Menu extends NinePatchRect

@export var telas : Dictionary[String, VBoxContainer] = {}

var caminho_configuracoes = "user://config.json"

@export var configuracoes : Array = []

func _ready() -> void:
	fechar_telas()
	$Principal/Jogar.pressed.connect(fechar_telas)
	$Principal/Opções.pressed.connect(abrir_tela.bind("Opções"))
	$Opcoes/Voltar.pressed.connect(salvar_configuracoes)

	configuracoes.append($Opcoes/Daltonismo)
	configuracoes.append($Opcoes/Narrador)
	configuracoes.append($Opcoes/AltoContraste)

	carregar_configuracoes()

func abrir_tela(alvo : String):
	print("carregando tela \"" + alvo + "\"")
	var tela_existe = false
	for tela in telas.keys():
		if tela == alvo:
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
	else:
		print("não consegui abrir o arquivo das configurações!!!")

func carregar_configuracoes() -> void:
	var arquivo = FileAccess.open(caminho_configuracoes, FileAccess.READ)
	if arquivo:
		var dados_json = arquivo.get_as_text()
		var dados_config = JSON.parse_string(dados_json)

		if dados_config != null:
			for config in configuracoes:
				if config is BotaoToggle:
					if dados_config.contains(config.id):
						config.valor = dados_config[config.id]
					else: print("configuração \"" + config.id + "\" não está no arquivo: valor padrão será utilizado")

		print("configurações carregadas")
	else:
		print("não consegui abrir o arquivo das configurações!!!")
