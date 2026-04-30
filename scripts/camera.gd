extends Camera3D

@onready var offset : Vector3 = position
@export var alvo : Node3D
@export var velocidade : float = 10.0

var realPosition : Vector3 = position

var i : float = 0;
var animationIntensity : float = 0

func _process(delta: float) -> void:
	var posicao_alvo = offset + alvo.position

	realPosition = Vector3(
		lerpf(realPosition.x, posicao_alvo.x, delta * velocidade),
		lerpf(realPosition.y, posicao_alvo.y, delta * velocidade),
		lerpf(realPosition.z, posicao_alvo.z, delta * velocidade)
	)

	if animationIntensity < 0.05 and alvo.peso_animacao_andar > 0.1: # acabou de começar a se mover
		animationIntensity = alvo.peso_animacao_andar * 1
	elif animationIntensity != 0 and alvo.peso_animacao_andar == 0: # parou de se mover
		animationIntensity = max(animationIntensity - 2*delta, 0);
	elif alvo.peso_animacao_andar > 0.1: # está se movendo
		# vai, linearmente, aumentando a intensidade
		animationIntensity = min(animationIntensity, alvo.peso_animacao_andar) + 16*delta;	
	else: # não está se movendo
		animationIntensity = max(animationIntensity - 4*delta, 0);
	
	print(animationIntensity, "/", alvo.peso_animacao_andar)
	
		
	var camAnim = Vector3(sin(i) * 0.9, abs(cos(i)) * 0.7, 0) * animationIntensity;
	position = realPosition + camAnim;
	i += 6 * delta;
	
