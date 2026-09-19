# Código responsável pela parte do Skill Check do minigame
extends Node2D

# Tempo mínimo/máximo entre skill checks (em segundos)
# NOTA: se já houver uma skill check rolando, o código vai esperar
#	    a atual acabar para, em seguida, lançar a próxima
const MIN_TIME_BETWEEN_CHECKS : float = 1
const MAX_TIME_BETWEEN_CHECKS : float = 4

# A barra da skill check
@onready var bar : TextureRect = $CanvasLayer/Bar
@onready var bar_border : TextureRect = $CanvasLayer/CanvasLayer/BarBorder
# Área de acerto
@onready var area_rect: ColorRect = $CanvasLayer/Bar/Area
# Ponteiro
@onready var pointer_rect: ColorRect = $CanvasLayer/Bar/CanvasLayer/Bar/Pointer

# Ponto mínimo e máximo da barra
@onready var bar_min_x : float = 0
@onready var bar_max_x : float = bar.size.x

# Tempo até a próxima skill check
var next_check_time : float = -1

# Se há uma skill check atualmente
var skill_check_enabled : bool = false

func _ready() -> void:
	area_rect.visible = false
	pointer_rect.visible = false


func _process(delta: float) -> void:
	next_check_time -= delta

	if next_check_time < 0 and not skill_check_enabled:
		next_check_time = randf_range(MIN_TIME_BETWEEN_CHECKS, MAX_TIME_BETWEEN_CHECKS)
		skill_check()



func skill_check() -> void:
	pass