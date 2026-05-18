class_name Menu extends Control

class MenuData:
	var node : Control
	var objetos : Array
	var botoes : Array[ConfigButton]
	var idx_ativo : int = 0
	var guardar_idx : bool = false

	func _init(_node : Control, _objetos : Array, _botoes : Array[ConfigButton], _guardar_idx : bool = false):
		node = _node
		objetos = _objetos
		botoes = _botoes
		guardar_idx = _guardar_idx

@export var telas : Dictionary[String, VBoxContainer] = {}

var caminho_configuracoes = "user://config.json"

@export var configuracoes : Array = []

## Configurações do Menu Circular ##

# Índice da opção do menu atual
var idx_opcao_atual : int = 0
# "Índice" da posição opção do menu atual 
var posicao_opcao_atual : int = 0

# Dicionário com todos os menus e seus botões
var menus : Dictionary = {}
var menu_ativo : String = "Principal"

# Tamanho do raio da circunferência do Menu
const raio_menu_base : int = 1000
var raio_menu : int = 1000

# Distância do meio da circunferência do Menu pro meio da tela
const centro_menu_offset : Vector2 = Vector2(1000, 0);

# Ângulo, em radiano, entre os botões
const angulo_menu : float = 0.1

# Distância do botão selecionado da circunferência
const offset_botao_selecionado : float = 0

# Escala do botão selecionado
const escala_botao_selecionado : float = 1.0

# Ângulo inicial do menu
const angulo_inicial : float = PI # centralizado

# Tamanho do botão. Esses valores sãos definidos automaticamentes
var botao_tamanho_x : float
var botao_tamanho_y : float 


func _ready() -> void:
	fechar_telas()
	inicializa_menus()
	inicializar_botoes_circulares()

	for configuracao in $Telas/Configuracoes.get_children():
		if configuracao is ConfigButton and "valor" in configuracao:
			configuracoes.append(configuracao)
	for configuracao in $Telas/Acessibilidade.get_children():
		if configuracao is ConfigButton and "valor" in configuracao:
			configuracoes.append(configuracao)
	for configuracao in $Telas/Controles.get_children():
		if configuracao is ConfigButton and "valor" in configuracao:
			configuracoes.append(configuracao)

	# carregar_configuracoes()
	
	abrir_tela("Principal")

# Função chamada a cada frame
func _process(_delta: float) -> void:
	# dps troca isso pra funcionar com todos os menus ou sla não sei como vcs querem fazer

	# Renderiza os botões do menu principal
	atualizar_botoes_circulares(menus[menu_ativo], _delta)

"""
Atualiza a posição dos botões em uma organização circular a lista de botões dado 
@param lista_botoes array dos botões que deverão ser posicionados na tela
"""
func atualizar_botoes_circulares(menu_data : MenuData, delta : float):
	var lista_botoes = menu_data.botoes
	var lista_objetos = menu_data.objetos

	# Atualiza o index para apontar para o botao com foco
	idx_opcao_atual = buscar_foco(lista_botoes)
	posicao_opcao_atual = lista_objetos.find(lista_botoes[idx_opcao_atual])
	
	$Ponteiro.label_settings.outline_color = lerp($Ponteiro.label_settings.outline_color, lista_botoes[idx_opcao_atual].pressed_color, delta / 0.1)
	$Ponteiro.label_settings.font_color = lerp($Ponteiro.label_settings.font_color, lista_botoes[idx_opcao_atual].focus_color, delta / 0.1)

	# Percorre todos os botões, definindo a posição de cada um
	for i in range(lista_objetos.size()):
		var button : Control = lista_objetos[i]

		# Índice relativo à opção selecionada atualmente
		var idx_relativo : int = i - posicao_opcao_atual

		# Obtém o fator da escala para diminuir os botões mais distantes e aumentar o botão selecionado
		var fator_escala : float = (escala_botao_selecionado if idx_relativo == 0 else 1.0) * pow(.8, abs(idx_relativo))
		
		# Aplica o fator_escala no botão
		button.scale = lerp(button.scale, Vector2(fator_escala, fator_escala), delta / 0.1)

		# Diminui a opacidade dos botões distantes
		var opacidade = clampf(1.0 - max(0, abs(idx_relativo) - 2) * 0.34, 0, 1)
		button.modulate.a = lerp(button.modulate.a, opacidade, delta / 0.1)

	# Gira a tela inteira para deixar o botao selecionado na esquerda
	var angulo : float = posicao_opcao_atual * angulo_menu
	$Telas.rotation = lerp($Telas.rotation, angulo, delta / 0.1)

func inicializar_botoes_circulares():
	# Percorre todos os botões, definindo a posição de cada um
	for menu in menus.values():
		for i in range(menu.objetos.size()):
			var objeto : Control = menu.objetos[i]

			var angulo : float = (i * angulo_menu) - angulo_inicial
			if objeto is Label:
				angulo += angulo_menu / 2

			# Calcula e define a posição do botão
			var x : float = (cos(angulo) * raio_menu)
			var y : float = -(sin(angulo) * raio_menu)
			objeto.position = Vector2(x, y)
			# Aponta o botão para o centro do círculo
			objeto.rotation = PI - angulo

func buscar_foco(lista_botoes : Array) -> int:
	for i in range(lista_botoes.size()):
		var button : ConfigButton = lista_botoes[i]
		if button.has_focus():
			return i
	return idx_opcao_atual

func abrir_tela(alvo : String):
	print("carregando tela \"" + alvo + "\"")
	if alvo in menus.keys():
		for menu in menus.keys():
			if menu == alvo:
				idx_opcao_atual = menus[menu].idx_ativo if menus[menu].guardar_idx else 0
				menu_ativo = menu
				menus[menu].botoes[idx_opcao_atual].grab_focus()
				menus[menu].node.visible = true
				visible = true
				get_tree().paused = true
			else:
				menus[menu].node.visible = false
	else:
		print("tela \"" + alvo + "\" não existe!!!")

func fechar_telas():
	visible = false
	get_tree().paused = false
	for menu in menus.values():
		menu.node.visible = false

func salvar_configuracoes() -> void:
	var dados_config = {}
	for config in configuracoes:
		var botao
		if config is ConfigButtonBool: botao = config as ConfigButtonBool
		if config is ConfigButtonInt: botao = config as ConfigButtonInt
		if config is ConfigButtonFloat: botao = config as ConfigButtonFloat
		if config is ConfigButtonString: botao = config as ConfigButtonString
		if config is ConfigButtonList: botao = config as ConfigButtonList
		if config is ConfigButtonKeybind: botao = config as ConfigButtonKeybind

		if not botao:
			# se for label
			continue
		var nome = botao.id
		var valor = botao.valor
		dados_config[nome] = valor

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
				if config.id in dados_config:
					config.valor = dados_config[config.id]

				else: print("configuração \"" + config.id + "\" não está no arquivo: valor padrão será utilizado")
				# if config.id == "alto-contraste":
				# 	if config.valor == 0:
				# 		print("ativando o modo alto-contraste")
				# 		theme = preload("res://themes/alto_contraste.tres")
				# 	else:
				# 		print("desativando o modo alto-contraste")
				# 		theme = preload("res://themes/default.tres")
				# 	atualizar_visual_botoes()
				# if config.id == "escala-interface":
				# 	if config.valor == 0:
				# 		get_tree().root.content_scale_factor = 1.0
				# 	elif config.valor == 1:
				# 		get_tree().root.content_scale_factor = 1.5
				# 	elif config.valor == 2:
				# 		get_tree().root.content_scale_factor = 0.5

		# print("configurações carregadas:\n" + str(dados_config))
		MestreSupremo.aplicar_configuracoes(dados_config)
		print("configurações carregadas:\n" + str(MestreSupremo.configuracoes))
		arquivo.close()
	else:
		print("não consegui abrir o arquivo das configurações!!!")
	
	raio_menu = int(raio_menu_base / get_tree().root.content_scale_factor)
	var metade_tela : Vector2 = get_viewport_rect().size / 2
	var centro_circulo : Vector2 = (metade_tela + centro_menu_offset)
	$Telas.position = centro_circulo
	$Ponteiro.position = centro_circulo - Vector2(raio_menu_base + 20, 8)

# Função chamada quando há alguma entrada do usuário
func _input(event: InputEvent) -> void:
	# A opção atual aumenta (positivo) quando aperta para baixo e
	# diminui (negativo) quando aperta para cima
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
		idx_opcao_atual += int(event.is_action_pressed("ui_down")) - int(event.is_action_pressed("ui_up"));
		idx_opcao_atual = (idx_opcao_atual + menus[menu_ativo].botoes.size()) % menus[menu_ativo].botoes.size()
		menus[menu_ativo].botoes[idx_opcao_atual].grab_focus()
		menus[menu_ativo].idx_ativo = idx_opcao_atual
		accept_event()

func inicializa_menus():
	
	# PRINCIPAL

	menus["Principal"] = MenuData.new($Telas/Principal, [], [], true)

	$Telas/Principal/BotaoJogar.connect("pressed", fechar_telas)
	$Telas/Principal/BotaoConfiguracoes.connect("pressed", abrir_tela.bind("Configuracoes"))
	$Telas/Principal/BotaoAcessibilidade.connect("pressed", abrir_tela.bind("Acessibilidade"))
	$Telas/Principal/BotaoSair.connect("pressed", get_tree().quit)

	for filho in $Telas/Principal.get_children():
		if filho is ConfigButton:
			menus["Principal"].botoes.append(filho)
			filho.size.x = 300
		menus["Principal"].objetos.append(filho)

	# CONFIGURAÇÕES
			
	menus["Configuracoes"] = MenuData.new($Telas/Configuracoes, [], [], true)
	for filho in $Telas/Configuracoes.get_children():
		if filho is ConfigButton:
			menus["Configuracoes"].botoes.append(filho)
			filho.size.x = 300
		menus["Configuracoes"].objetos.append(filho)

	$Telas/Configuracoes/BotaoSalvar.connect("pressed", func():
		salvar_configuracoes()
		menus["Configuracoes"].idx_ativo = 0
		abrir_tela("Principal")
	)
	$Telas/Configuracoes/BotaoControles.connect("pressed", abrir_tela.bind("Controles"))

	# ACESSIBILIDADE

	menus["Acessibilidade"] = MenuData.new($Telas/Acessibilidade, [], [])
	for filho in $Telas/Acessibilidade.get_children():
		if filho is ConfigButton:
			menus["Acessibilidade"].botoes.append(filho)
			filho.size.x = 300
		menus["Acessibilidade"].objetos.append(filho)

	$Telas/Acessibilidade/BotaoSalvar.connect("pressed", func():
		salvar_configuracoes()
		abrir_tela("Principal")
	)

	# CONTROLES

	menus["Controles"] = MenuData.new($Telas/Controles, [], [])
	for filho in $Telas/Controles.get_children():
		if filho is ConfigButton:
			menus["Controles"].botoes.append(filho)
			filho.size.x = 300
		menus["Controles"].objetos.append(filho)

	$Telas/Controles/BotaoSalvar.connect("pressed", func():
		salvar_configuracoes()
		abrir_tela("Configuracoes")
	)
