extends Area2D

var timeToLive = 0.5
var velocity = Vector2(0, 0)

func _ready():
	#("Prj spawn v: " + str(velocity.x) + ", " + str(velocity.y))
		pass

func _process(delta):
	timeToLive -= delta
	if timeToLive <= 0:
		# remove self
		#print("Projectile die")
		get_parent().queue_free()
		pass
	var step = Vector2(velocity.x * delta, velocity.y * delta)
	position += step
