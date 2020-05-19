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
	var mask = -1
	# var mask = com.LAYER_WORLD | com.LAYER_ENTITIES
	
	var space = get_world().direct_space_state
	var result = space.intersect_ray(origin, dest, [], mask)
	var finalPos: Vector3 = dest
	if result:
		m_realPos = result.position
		# move back slightly from impact point or will draw IN the geometry
		# don't move out by normal, this will cause quick shots
		# against extreme angles to miss as the laser will poke out from the surface
		#print("Laser hit layer " + str(result.collider.collision_layer))
		var layer: int = result.collider.collision_layer

		var intersectObj: bool = false
		if (layer & com.LAYER_ITEMS) != 0:
			intersectObj = true
		if (layer & com.LAYER_ENTITIES) != 0:
			intersectObj = true
		
		if intersectObj:
			# move flight position for disc slightly INTO damagable objects
			m_discPos = result.position + (forward * 0.2)
		else:
			m_discPos = result.position - (forward * 2)

		# position for display of laser
		finalPos = result.position - (forward * 0.25)
		# TODO: set forward angle to normal of impact surface
	else:
		m_realPos = finalPos
		m_discPos = finalPos

	self.global_transform.origin = finalPos
	com.debugSpawnPosition = finalPos
