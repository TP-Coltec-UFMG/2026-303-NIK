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

@export var botoes_configuracao : Array = []

## Configurações do Menu Circular ##
var menu_circular : bool = true:
	set(valor):
		menu_circular = valor
		atualizar_botoes_circulares(-1)
		

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
# Distância, em pixels, entre os botões 
const distancia_menu : float = 64

# Distância do botão selecionado da circunferência
const offset_botao_selecionado : float = 0

# Escala do botão selecionado
const escala_botao_selecionado : float = 1.0

# Ângulo inicial do menu
const angulo_inicial : float = PI # centralizado

func _ready() -> void:
	fechar_telas()
	inicializar_menus()
	inicializar_botoes_circulares()

	for botao in $Telas/Configuracoes.get_children():
		if botao is ConfigButton and "valor" in botao:
			botoes_configuracao.append(botao)
	for botao in $Telas/Acessibilidade.get_children():
		if botao is ConfigButton and "valor" in botao:
			botoes_configuracao.append(botao)
	for botao in $Telas/Controles.get_children():
		if botao is ConfigButton and "valor" in botao:
			botoes_configuracao.append(botao)

	# carregar_configuracoes()
	
	# abrir_tela("Principal")

# Função chamada a cada frame
func _process(delta: float) -> void:
	# Atualiza os botões do menu principal
	atualizar_botoes_circulares(delta)

"""
Atualiza a posição dos botões em uma organização circular a lista de botões dado 
@param menu_data estrutura com os dados do menu ativo
"""
func atualizar_botoes_circulares(delta : float):
	var menu_data = menus[menu_ativo]
	var lista_botoes = menu_data.botoes
	var lista_objetos = menu_data.objetos

	# Atualiza o index para apontar para o botao com foco
	idx_opcao_atual = buscar_foco(lista_botoes)
	posicao_opcao_atual = lista_objetos.find(lista_botoes[idx_opcao_atual])

	# Percorre todos os botões, definindo a posição de cada um
	for i in range(lista_objetos.size()):
		var button : Control = lista_objetos[i]

		# Índice relativo à opção selecionada atualmente
		var idx_relativo : int = i - posicao_opcao_atual

		# Obtém o fator da escala para diminuir os botões mais distantes e aumentar o botão selecionado
		var fator_escala : float = (escala_botao_selecionado if idx_relativo == 0 else 1.0) * pow(.8, abs(idx_relativo))
		
		# Aplica o fator_escala no botão
		button.scale = lerp(button.scale, Vector2(fator_escala, fator_escala), (delta / 0.1) if delta > 0 else 1.0)

		# Diminui a opacidade dos botões distantes
		var opacidade = clampf(1.0 - max(0, abs(idx_relativo) - 2) * 0.34, 0, 1)
		button.modulate.a = lerp(button.modulate.a, opacidade, (delta / 0.1)  if delta > 0 else 1.0)

	# Gira a tela inteira para deixar o botao selecionado na esquerda
	var angulo : float = posicao_opcao_atual * angulo_menu * get_tree().root.content_scale_factor
	var posicao : Vector2 = get_viewport_rect().size / 2 + centro_menu_offset / get_tree().root.content_scale_factor

	if not menu_circular: 
		angulo = 0
		posicao.y -= posicao_opcao_atual * distancia_menu

	$Telas.rotation = lerp($Telas.rotation, angulo, (delta / 0.1) if delta > 0 else 1.0)
	$Telas.position = lerp($Telas.position, posicao, (delta / 0.1) if delta > 0 else 1.0)
	
	$Ponteiro.label_settings.outline_color = lerp($Ponteiro.label_settings.outline_color, get_theme_color("cor_foco_contorno", lista_botoes[idx_opcao_atual].variacao_tema), (delta / 0.1) if delta > 0 else 1.0)
	$Ponteiro.label_settings.font_color = lerp($Ponteiro.label_settings.font_color, get_theme_color("cor_foco", lista_botoes[idx_opcao_atual].variacao_tema), (delta / 0.1) if delta > 0 else 1.0)
	
	if not menu_circular: 
		$Ponteiro.position.x = lerp($Ponteiro.position.x, (get_viewport_rect().size.x / 2 + centro_menu_offset.x - raio_menu_base - 20) - 20 * sin(abs($Telas.position.y - posicao.y) / distancia_menu), (delta / 0.05) if delta > 0 else 1.0)
	else:
		$Ponteiro.position.x = lerp($Ponteiro.position.x, (get_viewport_rect().size.x / 2 + centro_menu_offset.x - raio_menu_base - 20) - 20 * sin(abs($Telas.rotation - angulo) / (angulo_menu * get_tree().root.content_scale_factor)), (delta / 0.05) if delta > 0 else 1.0)
	$Ponteiro.position.y = get_viewport_rect().size.y / 2 + centro_menu_offset.y - (10 if menu_circular else 8) 

func inicializar_botoes_circulares():
	raio_menu = int(raio_menu_base / get_tree().root.content_scale_factor)
	
	# Percorre todos os botões, definindo a posição de cada um
	for menu in menus.values():
		for i in range(menu.objetos.size()):
			var objeto : Control = menu.objetos[i]

			var angulo : float = (i * angulo_menu * get_tree().root.content_scale_factor) - angulo_inicial
			if objeto is Label:
				angulo += angulo_menu * get_tree().root.content_scale_factor / 2

			# Calcula e define a posição do botão
			var x : float = (cos(angulo) * raio_menu)
			var y : float = -(sin(angulo) * raio_menu)
			
			if not menu_circular: 
				x = -raio_menu
				y = i * distancia_menu
				angulo = -PI
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
				posicao_opcao_atual = menus[menu].objetos.find(menus[menu].botoes[idx_opcao_atual])
				menu_ativo = menu
				menus[menu].botoes[idx_opcao_atual].grab_focus()
				menus[menu].node.visible = true
				visible = true
				get_tree().paused = true
				
				# vai imediatamente para a posição do menu novo
				var posicao : Vector2 = get_viewport_rect().size / 2 + centro_menu_offset / get_tree().root.content_scale_factor
				var angulo : float = posicao_opcao_atual * angulo_menu * get_tree().root.content_scale_factor
				
				if not menu_circular:
					angulo = 0
					posicao.y -= (posicao_opcao_atual) * distancia_menu

				$Telas.position = posicao
				$Telas.rotation = angulo
				atualizar_botoes_circulares(-1)
			else:
				menus[menu].node.visible = false
	else:
		print("tela \"" + alvo + "\" não existe!!!")

func fechar_telas():
	visible = false
	get_tree().paused = false
	for menu in menus.values():
		menu.node.visible = false

func carregar_configuracoes() -> void:
	var configuracoes = MestreSupremo.configuracoes
	for botao in botoes_configuracao:
		if botao.id in configuracoes:
			if botao.valor != configuracoes[botao.id]:
				if not botao is ConfigButtonList:
					botao.valor = configuracoes[botao.id]
				else:
					if configuracoes[botao.id] in botao.valores:
						botao._valor = botao.valores.find(configuracoes[botao.id])
					else: botao._valor = 0

# Função chamada quando há alguma entrada do usuário
func _input(event: InputEvent) -> void:
	if not get_tree().paused: 
		if event.is_action_pressed("pausar"):
			abrir_tela("Principal")
	# A opção atual aumenta (positivo) quando aperta para baixo e
	# diminui (negativo) quando aperta para cima
	if event.is_action_pressed("ui_down") or event.is_action_pressed("ui_up"):
		idx_opcao_atual += int(event.is_action_pressed("ui_down")) - int(event.is_action_pressed("ui_up"));
		idx_opcao_atual = (idx_opcao_atual + menus[menu_ativo].botoes.size()) % menus[menu_ativo].botoes.size()
		menus[menu_ativo].botoes[idx_opcao_atual].grab_focus()
		menus[menu_ativo].idx_ativo = idx_opcao_atual
		accept_event()
func inicializar_menus():
	
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

func salvar_configuracoes() -> void:
	MestreSupremo.salvar_configuracoes()
