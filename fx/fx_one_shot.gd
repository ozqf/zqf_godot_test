extends Spatial

onready var particles = $particles

var tick: float = 2

func _ready():
	particles.emitting = true

func _process(_delta: float):
	tick -= _delta
	if tick <= 0:
		queue_free()
