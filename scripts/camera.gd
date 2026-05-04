extends Camera3D

@export var offset : Vector3
@export var offset_pausa : Vector3
@export var alvo : Node3D
@export var velocidade : float = 10.0

var posicao_real : Vector3 = position

var balanco : float = 0;
var tempo_balanco : float = 0;
var offset_balanco : Vector3 = Vector3.ZERO
var offset_balanco_alvo : Vector3 = Vector3.ZERO
var intensidade_balanco = 30
var balanco_camera : bool = false

func _process(delta: float) -> void:
	var posicao_alvo = alvo.position
	# position.x = lerpf(position.x, posicao_alvo.x, delta * velocidade)
	# position.y = lerpf(position.y, posicao_alvo.y, delta * velocidade)
	# position.z = lerpf(position.z, posicao_alvo.z, delta * velocidade)

	# posicao_real = Vector3(
	# 	lerpf(posicao_real.x, posicao_alvo.x, delta * velocidade),
	# 	lerpf(posicao_real.y, posicao_alvo.y, delta * velocidade),
	# 	lerpf(posicao_real.z, posicao_alvo.z, delta * velocidade)
	# )

	if not get_tree().paused:
		# if intensidade_animacao < 0.05 and alvo.peso_animacao_andar > 0.1: # acabou de começar/parar o movimento
		# 	intensidade_animacao = alvo.peso_animacao_andar * 1
		# elif intensidade_animacao != 0 and alvo.peso_animacao_andar == 0: # parou de se mover
		# 	intensidade_animacao = max(intensidade_animacao - 2*delta, 0);
		# elif alvo.peso_animacao_andar > 0.1: # está se movendo
		# 	# vai, linearmente, aumentando a intensidade
		# 	intensidade_animacao = min(intensidade_animacao, alvo.peso_animacao_andar) + 16*delta;	
		# else: # não está se movendo
		# 	intensidade_animacao = max(intensidade_animacao - 4*delta, 0);
	
		offset_balanco = offset_balanco.lerp(offset_balanco_alvo, delta * 5)
		if balanco >= tempo_balanco:
			offset_balanco_alvo = Vector3((randf() - 0.5) * intensidade_balanco, (randf() - 0.5) * intensidade_balanco, 0)
			tempo_balanco = (randf() * .15)
			balanco = 0
		balanco += randf() * 6 * delta;

		posicao_alvo = posicao_alvo + offset + ((offset_balanco * alvo.peso_animacao_andar) if balanco_camera else Vector3.ZERO);
	else:
		posicao_alvo = posicao_alvo + offset_pausa;

	position = position.lerp(posicao_alvo, delta * velocidade)
	
