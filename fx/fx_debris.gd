extends RigidBody

var m_tick: float = 6

func _process(_delta: float):
	if m_tick <= 0:
		queue_free()
		return
	m_tick -= _delta

func throw_randomly():
	var force: float = 10
	var v: Vector3 = Vector3()
	v.y = rand_range(0, force * 2)
	v.x = rand_range(-force, force)
	v.z = rand_range(-force, force)
	linear_velocity = v
	angular_velocity = v
