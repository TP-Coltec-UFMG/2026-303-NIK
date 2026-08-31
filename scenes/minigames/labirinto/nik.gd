class_name nik extends CharacterBody2D

@export var Labirinto: Labirinto
var posicao_atual

func _ready() -> void:
	posicao_atual = Labirinto.transformador(position.y, position.x)


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("move_up") or Input.is_action_just_pressed("ui_up"):
		if Labirinto.verificar_caminho(posicao_atual[0]-1, posicao_atual[1]):
			position.y -= 450
			posicao_atual = Labirinto.transformador(position.y, position.x)
			
	if Input.is_action_just_pressed("move_right") or Input.is_action_just_pressed("ui_right"):
		if Labirinto.verificar_caminho(posicao_atual[0], posicao_atual[1]+1):
			position.x += 450
			posicao_atual = Labirinto.transformador(position.y, position.x)
			
	if Input.is_action_just_pressed("move_down") or Input.is_action_just_pressed("ui_down"):
		if Labirinto.verificar_caminho(posicao_atual[0]+1, posicao_atual[1]):
			position.y += 450
			posicao_atual = Labirinto.transformador(position.y, position.x)
			
	if Input.is_action_just_pressed("move_left") or Input.is_action_just_pressed("ui_left"):
		if Labirinto.verificar_caminho(posicao_atual[0], posicao_atual[1]-1):
			position.x -= 450
			posicao_atual = Labirinto.transformador(position.y, position.x)
