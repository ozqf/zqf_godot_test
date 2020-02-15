extends Area

var velocity: Vector3 = Vector3()
var tickTime: float = 1

func _physics_process(_delta: float):
	var pos = transform.origin
	pos += (velocity * _delta)
	transform.origin = pos

func _process(delta: float):
	tickTime -= delta
	if tickTime <= 0:
		queue_free()

func _on_projectile_body_entered(body):
	var hp: Node = body.get_node("Health")
	if hp != null:
		print("Prj hit obj with hp")
	else:
		print("Prj hit but no hp")
	tickTime = 0
