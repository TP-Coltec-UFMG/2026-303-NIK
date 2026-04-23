class_name ControleDialogo extends NinePatchRect

class Dialogo:
	var id : String = "id único do diálogo"
	var texto : String = "texto do npc"
	var opcoes : Array[Escolhas]

class Escolhas:
	enum TIPO_ESCOLHA { INVESTIGACAO, RESPOSTA, SAIR }
	var nome : String = "texto do botão"
	var proximo_dialogo : String = "id do próximo diálogo"
	var tipo : TIPO_ESCOLHA = TIPO_ESCOLHA.INVESTIGACAO

@onready var texto : RichTextLabel = $Texto
@export var cena_opcao : PackedScene
var dialogo_ativo : String

@export var banco_de_dialogos : Dictionary = {}

func _ready() -> void:
	var d1 = Dialogo.new()
	d1.id = "inicio"
	d1.texto = "[b][color=#584599]Paulo[/color][/b]\nQual o seu nome, vizinha?"

	var d2 = Dialogo.new()
	d2.id = "quem_e"
	d2.texto = "[b][color=#584599]Paulo[/color][/b]\nPrazer, Nikole. Eu me chamo Paulo."
	
	var e1 = Escolhas.new()
	e1.nome = "Se apresentar"
	e1.proximo_dialogo = "quem_e"
	e1.tipo = Escolhas.TIPO_ESCOLHA.INVESTIGACAO
	
	var e2 = Escolhas.new()
	e2.nome = "Adeus."
	e2.proximo_dialogo = "fim"
	e2.tipo = Escolhas.TIPO_ESCOLHA.SAIR
	
	d1.opcoes.append(e1)
	d1.opcoes.append(e2)
	d2.opcoes.append(e2)
	banco_de_dialogos[d1.id] = d1
	banco_de_dialogos[d2.id] = d2
	
	carregar_dialogo("inicio")

func carregar_dialogo(dialogo : String):
	dialogo_ativo = dialogo
	gerar_opcoes()

func gerar_opcoes():
	var dados_atuais : Dialogo = banco_de_dialogos[dialogo_ativo]
	
	texto.text = dados_atuais.texto
	
	for filho in $PainelEscolhas.get_children():
		filho.queue_free()
	
	var contagem = 1;
	for escolha in dados_atuais.opcoes:
		var botao = cena_opcao.instantiate()
		botao.configurar(str(contagem) + ". " + escolha.nome, escolha.tipo)
			
		botao.pressed.connect(_ao_escolher_opcao.bind(escolha.proximo_dialogo))
		
		$PainelEscolhas.add_child(botao)
		contagem += 1

func _ao_escolher_opcao(proximo_id: String):
	if proximo_id == "fim":
		print("Fim da conversa")
		self.visible = false
		Transicao.carregar_cena_principal()
	else:
		carregar_dialogo(proximo_id)
