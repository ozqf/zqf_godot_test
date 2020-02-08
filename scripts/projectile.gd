extends Area2D

var timeToLive = 1
var velocity = Vector2(0, 0)

signal hit

func _process(delta):
	timeToLive -= delta
	if timeToLive <= 0:
		# remove self
		#print("Projectile die")
		get_parent().queue_free()
		return
	var step = Vector2(velocity.x * delta, velocity.y * delta)
	position += step


func _on_Area2D_body_entered(body):
	
	var hp: Node = body.get_node("Health")
	if hp == null:
		print("Prj hit but no hp found")
		return
	if hp.team == 1:
		return
	print("Prj hit " + str(hp))
	timeToLive = 0
	emit_signal("hit")
