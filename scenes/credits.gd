extends CanvasLayer

const INITIAL_SCALE : float = 1.2

const MUSIC_FADE_TIME : float = 7.5

func _ready() -> void:
	$BlackRect.visible = true

	self.scale = Vector2(INITIAL_SCALE, INITIAL_SCALE)
	self.offset = Vector2( -(INITIAL_SCALE - 1) * 1280 / 2, -(INITIAL_SCALE - 1) * 720 / 2)
	
	await GameManager.play_music('new_life')

	while GameManager.music_player.playing and GameManager.music_player.get_playback_position() < MUSIC_FADE_TIME:
		await get_tree().process_frame

	fade_out()

func fade_out() -> void:
	var tween : Tween = create_tween()
	tween\
		.tween_property($BlackRect, 'modulate:a', 0, 0.5)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)

	# Diminui o tamanho e mantém centralizado
	tween\
		.parallel()\
		.tween_property(self, 'scale', Vector2(1, 1), 0.6)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)
	tween\
		.parallel()\
		.tween_property(self, 'offset', Vector2(0, 0), 0.6)\
		.set_trans(Tween.TRANS_QUART)\
		.set_ease(Tween.EASE_OUT)



func _on_back_pressed() -> void:
	GameManager.play_music('neighborhood')
	GameManager.load_scene("home_menu")