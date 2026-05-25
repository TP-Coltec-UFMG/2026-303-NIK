extends CanvasLayer

var tags = {}
var personagens : Dictionary[String, Dictionary] = {}
var dialogos = {}
var dialogo_atual : ArvoreDialogo
const arquivo_dialogos = "res://dialogos.json"

@onready var container_opcoes = $Interface/CaixaDialogo/Conteudo/ScrollContainer/Opcoes
@onready var dialogo_texto = $Interface/CaixaDialogo/Conteudo/Dialogo
@onready var interface = $Interface
@onready var interlocutor = $Interface/Interlocutor

var ativo = false;
var tween : Tween

func _ready() -> void:
	ler_arquivo_dialogos()
	iniciar_dialogo("")

func iniciar_dialogo(dialogo : String):
	if dialogo == "" or not dialogos.has(dialogo):
		dialogo_atual = null
		fechar_tela()
		ativo = false
		return

	dialogo_atual = dialogos[dialogo]

	interlocutor.texture = load("res://sprites/dialogo/personagens/" + dialogo_atual.personagem + ".png") # res://sprites/dialogo/personagens/Pedro.png
	visible = true
	if dialogo in dialogos: dialogo_atual = dialogos[dialogo]

	dialogo_texto.text = dialogo_atual.personagem + ": " + dialogo_atual.texto
	iniciar_opcoes()

	abrir_tela()

func iniciar_opcoes():
	for obj in container_opcoes.get_children():
		container_opcoes.remove_child(obj)
		obj.queue_free()
		
	var n : int = 1

	for escolha in dialogo_atual.escolhas:
		var exibir = true
		
		for tag in escolha.tags_proibidas:
			if tags.has(tag):
				exibir = false 

		for tag in escolha.tags_proibidas_personagem:
			if personagens[dialogo_atual.personagem].has(tag):
				exibir = false 

		for tag in escolha.tags_necessarias:
			if not tags.has(tag):
				exibir = false 

		for tag in escolha.tags_necessarias_personagem:
			if not personagens[dialogo_atual.personagem].has(tag):
				exibir = false 

		if not exibir: 
			continue
		
		var botao = DialogButton.new()
		botao.label = str(n) + ". " + escolha.texto
		botao.proxima_arvore = escolha.proxima_arvore
		
		botao.tags_adicionar = escolha.tags_adicionadas
		botao.tags_adicionar_personagem = escolha.tags_adicionadas_personagem 
		
		container_opcoes.add_child(botao)
		if n == 1:
			botao.grab_focus()
		n += 1

func ler_arquivo_dialogos():
	var arquivo = FileAccess.open(arquivo_dialogos, FileAccess.READ)
	if arquivo:
		var dados_json = arquivo.get_as_text()
		var dados_dialogos = JSON.parse_string(dados_json)

		if dados_dialogos != null:
			dialogos = {}
			for dialogo in dados_dialogos:
				var escolhas : Array[EscolhaDialogo] = []
				for escolha in dialogo.escolhas:
					var necessarias : Array[String] = []
					necessarias.assign(escolha.get("tags_necessarias", []))
					
					var proibidas : Array[String] = []
					proibidas.assign(escolha.get("tags_proibidas", []))
					
					var adicionadas : Array[String] = []
					adicionadas.assign(escolha.get("tags_adicionadas", []))


					var necessarias_personagem : Array[String] = []
					necessarias_personagem.assign(escolha.get("tags_personagem_necessarias", [])) 

					var proibidas_personagem : Array[String] = []
					proibidas_personagem.assign(escolha.get("tags_personagem_proibidas", [])) 

					var adicionadas_personagem : Array[String] = []
					adicionadas_personagem.assign(escolha.get("tags_personagem_adicionadas", []))

					escolhas.append(EscolhaDialogo.new(escolha.texto, necessarias, proibidas, adicionadas, necessarias_personagem, proibidas_personagem, adicionadas_personagem, escolha.get("proxima_arvore", "")))
				
				if dialogo.personagem not in personagens.keys():
					personagens[dialogo.personagem] = {}
				dialogos[dialogo.id] = ArvoreDialogo.new(dialogo.id, dialogo.personagem, dialogo.texto, escolhas)

		print("diálogos carregados!\n")
		arquivo.close()
	else:
		printerr("não consegui abrir o arquivo dos diálogos!!!")

func adicionar_tags(tags_adicionar : Array[String]):
	for tag in tags_adicionar:
		tags[tag] = true

func adicionar_tags_personagem(tags_adicionar : Array[String]):
	for tag in tags_adicionar:
		personagens[dialogo_atual.personagem][tag] = true

func abrir_tela() -> void:
	visible = true
	if tween:
		tween.kill()
		
	tween = create_tween()
	
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(interface, "position", Vector2.ZERO, 0.1)

	await tween.finished
	ativo = true

func fechar_tela() -> void:
	if tween:
		tween.kill()
		
	tween = create_tween()
	
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	
	tween.tween_property(interface, "position", Vector2(0, interface.get_viewport_rect().size.y), 0.1)

	await tween.finished
	ativo = false
	visible = false
	
