extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var fundo_preto = $Black
@export var cena_principal : PackedScene

func carregar_cena(cena: PackedScene) -> void:
	visible = true
	animation_player.play("fade")
	await animation_player.animation_finished
	
	get_tree().change_scene_to_packed(cena)
	
	await get_tree().process_frame 
	
	animation_player.play_backwards("fade")
	await animation_player.animation_finished
	visible = false

func carregar_cena_principal():
	carregar_cena(cena_principal)
