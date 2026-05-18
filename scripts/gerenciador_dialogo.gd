extends CanvasLayer

var dialogos = {}
var dialogo_atual : ArvoreDialogo

func iniciar_dialogo(dialogo : String):
	if dialogo in dialogos: dialogo_atual = dialogos[dialogo]

func iniciar_opcoes():
	var n : int = 1
	for escolha in dialogo_atual.escolhas:
		var botao = DialogButton.new()
		botao.label = str(n) + ". " + escolha.texto
		add_child(botao)
