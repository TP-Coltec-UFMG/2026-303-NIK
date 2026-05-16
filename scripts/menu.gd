class_name Menu extends Control

class MenuData:
	var node : Control
	var botoes : Array[ConfigButtonBase]

	func _init(_node : Control, _botoes : Array[ConfigButtonBase]):
		node = _node
		botoes = _botoes

@export var telas : Dictionary[String, VBoxContainer] = {}

var caminho_configuracoes = "user://config.json"

@export var configuracoes : Array = []

## Configurações do Menu Circular ##

# Índice da opção do menu atual
var idx_opcao_atual : int = 0

# Lista dos Botões do Menu Principal
var buttons_menu_principal : Array[ConfigButtonBase] = []

var menus : Dictionary = {}
var menu_ativo : String = "Principal"

# Tamanho do raio da circunferência do Menu
const raio_menu : int = 400

# Distância do meio da circunferência do Menu pro meio da tela
const centro_menu_offset : Vector2 = Vector2(-800, 0);

# Ângulo, em radiano, entre os botões
const angulo_menu : float = 0.3

# Distância do botão selecionado da circunferência
const offset_botao_selecionado : float = 0

# Escala do botão selecionado da circunferência
const escala_botao_selecionado : float = 1.0

# Ângulo inicial do menu
const angulo_inicial : float = PI # centralizado

# Tamanho do botão. Esses valores sãos definidos automaticamentes
var botao_tamanho_x : float
var botao_tamanho_y : float 


func _ready() -> void:
	abrir_tela("Menu")

	# Adiciona as labels na array de buttons_menu_principal
	for button in $Circular/Principal.get_children():
		buttons_menu_principal.append(button)

	inicializa_menus()

	# for configuracao in $PainelMenu/Opcoes.get_children():
	# 	if configuracao is ConfigButtonBase:
	# 		configuracoes.append(configuracao)

	#carregar_configuracoes()

# Função chamada a cada frame
func _process(_delta: float) -> void:
	# dps troca isso pra funcionar com todos os menus ou sla não sei como vcs querem fazer

	# Renderiza os botões do menu principal
	renderizarBotoes(menus[menu_ativo].botoes, _delta)

"""
Renderiza (posiciona e desenha na tela) em uma organização circular a lista de botões dado 
@param lista_botoes array dos botões que deverão ser posicionados na tela
"""
func renderizarBotoes(lista_botoes : Array, delta : float):
	var metade_tela : Vector2 = get_viewport_rect().size / 2
	var centro_circulo : Vector2 = metade_tela + centro_menu_offset

	# Percorre todos os botões, definindo a posição de cada um
	for i in range(lista_botoes.size()):
		var button : ConfigButtonBase = lista_botoes[i]

		# Índice relativo à opção selecionada atualmente
		var idx_relativo : int = i - idx_opcao_atual

		# (Só pra saber qual tá selecionado, dps troca)
		if i == idx_opcao_atual:
			button.add_theme_color_override("font_color", Color.BLUE)
		else:
			button.add_theme_color_override("font_color", Color.WHITE)


		var angulo : float = (idx_relativo * angulo_menu) - angulo_inicial

		# Obtém o fator da escala (vai transformar o intervalo do cosseno, [-1, 1],
		# em um intervalo [0, 1])
		# var fator_escala : float = ((cos( 0.4 * idx_relativo * PI/2) + 1 ) / 2) * (escala_botao_selecionado if idx_relativo == 0 else 1.0)
		var fator_escala : float = (escala_botao_selecionado if idx_relativo == 0 else 1.0) * pow(.8, abs(idx_relativo))

		# Calcula e define a posição do botão
		# var x : float = centro_circulo.x + (cos(angulo) * raio_menu) - raio_menu*fator_escala # subtrair pelo fator_escala deixa a curva mais acentuada!
		var x : float = centro_circulo.x + (cos(angulo) * raio_menu)
		var y : float = centro_circulo.y - (sin(angulo) * raio_menu)
		button.position = lerp(button.position, Vector2(x - (offset_botao_selecionado if idx_relativo == 0 else 0.0), y - ((button.size.y * fator_escala) / 2.0)), delta / 0.1)

		button.scale = lerp(button.scale, Vector2(fator_escala, fator_escala), delta / 0.1)


func abrir_tela(alvo : String):
	print("carregando tela \"" + alvo + "\"")
	if alvo in menus.keys():
		for menu in menus.keys():
			if menu == alvo:
				menus[menu].botoes[0].grab_focus()
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

# func salvar_configuracoes() -> void:
# 	abrir_tela("Menu")

# 	var dados_config = {}
# 	for config in configuracoes:
# 		if config is BotaoToggle:
# 			var nome = config.id
# 			var dado = config.valor
# 			dados_config[nome] = dado

# 	var dados_json = JSON.stringify(dados_config, "\t")
# 	var arquivo = FileAccess.open(caminho_configuracoes, FileAccess.WRITE)
# 	if arquivo:
# 		arquivo.store_string(dados_json)
# 		print("configurações salvas")
# 		arquivo.close()
# 	else:
# 		print("não consegui abrir o arquivo das configurações!!!")
# 	carregar_configuracoes()

# func carregar_configuracoes() -> void:
# 	var arquivo = FileAccess.open(caminho_configuracoes, FileAccess.READ)
# 	if arquivo:
# 		var dados_json = arquivo.get_as_text()
# 		var dados_config = JSON.parse_string(dados_json)

# 		if dados_config != null:
# 			for config in configuracoes:
# 				if config is BotaoToggle:
# 					if config.id in dados_config:
# 						config.valor = dados_config[config.id]
# 					else: print("configuração \"" + config.id + "\" não está no arquivo: valor padrão será utilizado")
# 				if config.id == "alto-contraste":
# 					if config.valor == 0:
# 						print("ativando o modo alto-contraste")
# 						theme = preload("res://themes/alto_contraste.tres")
# 					else:
# 						print("desativando o modo alto-contraste")
# 						theme = preload("res://themes/default.tres")
# 					atualizar_visual_botoes()
# 				if config.id == "escala-interface":
# 					if config.valor == 0:
# 						get_tree().root.content_scale_factor = 1.0
# 					elif config.valor == 1:
# 						get_tree().root.content_scale_factor = 1.5
# 					elif config.valor == 2:
# 						get_tree().root.content_scale_factor = 0.5

# 		print("configurações carregadas")
# 		arquivo.close()
# 	else:
# 		print("não consegui abrir o arquivo das configurações!!!")

# func atualizar_visual_botoes():
# 	for filho in get_children(true):
# 		if filho is BotaoToggle:
# 			filho.atualizar_visual()


# Função chamada quando há alguma entrada do usuário
func _input(event: InputEvent) -> void:
	# A opção atual aumenta (positivo) quando aperta para baixo e
	# diminui (negativo) quando aperta para cima
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
		idx_opcao_atual += int(event.is_action_pressed("ui_down")) - int(event.is_action_pressed("ui_up"));
		idx_opcao_atual = (idx_opcao_atual + menus[menu_ativo].botoes.size()) % menus[menu_ativo].botoes.size()
		menus[menu_ativo].botoes[idx_opcao_atual].grab_focus()
		accept_event()

func inicializa_menus():
	menus["Principal"] = MenuData.new($Circular/Principal, [])
	$Circular/Principal/ConfigButtonBase.connect("pressed", fechar_telas)

	for filho in $Circular/Principal.get_children():
		if filho is ConfigButtonBase:
			menus["Principal"].botoes.append(filho)
