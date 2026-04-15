class_name Nota extends MeshInstance3D

var velocidade: float = 10.0
var ativa = true
var semitons = 10

@onready var area_clique_perdao = get_parent().area_clique_perdao

func _process(delta: float) -> void:
	position.z += velocidade * delta
	
	if position.z > (4.5 + area_clique_perdao) and ativa:
		get_parent().remover_nota(self)
		ativa = false
	if position.z > 10.0:
		queue_free()
