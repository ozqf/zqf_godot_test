extends MeshInstance

var m_realPos: Vector3 = Vector3()
var m_realNormal: Vector3 = Vector3()

var m_discPos: Vector3 = Vector3()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var trans: Transform = get_parent().get_global_transform()
	var origin: Vector3 = trans.origin
	var forward: Vector3 = trans.basis.z
	forward = -forward
	var dest: Vector3 = origin + (forward * 1000)
	var mask = com.LAYER_WORLD | com.LAYER_ENTITIES
	
	var space = get_world().direct_space_state
	var result = space.intersect_ray(origin, dest, [], mask)
	var finalPos: Vector3 = dest
	if result:
		m_realPos = result.position
		# move back slightly from impact point or will draw IN the geometry
		# don't move out by normal, this will cause quick shots
		# against extreme angles to miss as the laser will poke out from the surface
		m_discPos = result.position - (forward * 2)
		finalPos = result.position - (forward * 0.25)
		# TODO: set forward angle to normal of impact surface
	else:
		m_realPos = finalPos
		m_discPos = finalPos

	self.global_transform.origin = finalPos
	com.debugSpawnPosition = finalPos
