# Código da tela de Game Over 💀😭❌

extends CanvasLayer

# Quando o botão de tentar novamente for pressioando
func _on_try_again_pressed() -> void:
	# Recarrega a cena
	get_tree().reload_current_scene()

# Quando o botão de sair for pressionado
func _on_exit_pressed() -> void:
	# Vai para o mapa principal
	GameManager.load_map()

