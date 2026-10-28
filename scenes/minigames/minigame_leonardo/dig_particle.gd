extends GPUParticles2D

func _ready():
	emitting = true
	finished.connect(queue_free)