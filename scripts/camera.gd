extends Camera3D

@onready var offset : Vector3 = position
@export var alvo : Node3D
@export var velocidade : float = 10.0

var posicao_real : Vector3 = position

var i : float = 0;
var intensidade_animacao : float = 0

func _process(delta: float) -> void:
	var posicao_alvo = offset + alvo.position
	position.x = lerpf(position.x, posicao_alvo.x, delta * velocidade)
	position.y = lerpf(position.y, posicao_alvo.y, delta * velocidade)
	position.z = lerpf(position.z, posicao_alvo.z, delta * velocidade)


	posicao_real = Vector3(
		lerpf(posicao_real.x, posicao_alvo.x, delta * velocidade),
		lerpf(posicao_real.y, posicao_alvo.y, delta * velocidade),
		lerpf(posicao_real.z, posicao_alvo.z, delta * velocidade)
	)

	if intensidade_animacao < 0.05 and alvo.peso_animacao_andar > 0.1: # acabou de começar a se mover
		intensidade_animacao = alvo.peso_animacao_andar * 1
	elif intensidade_animacao != 0 and alvo.peso_animacao_andar == 0: # parou de se mover
		intensidade_animacao = max(intensidade_animacao - 2*delta, 0);
	elif alvo.peso_animacao_andar > 0.1: # está se movendo
		# vai, linearmente, aumentando a intensidade
		intensidade_animacao = min(intensidade_animacao, alvo.peso_animacao_andar) + 16*delta;	
	else: # não está se movendo
		intensidade_animacao = max(intensidade_animacao - 4*delta, 0);
	
	print(intensidade_animacao, "/", alvo.peso_animacao_andar)
	
		
	var animacao_camera = Vector3(sin(i) * 0.9, abs(cos(i)) * 0.7, 0) * intensidade_animacao;
	position = posicao_real + animacao_camera;
	i += 6 * delta;
	