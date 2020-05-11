extends MeshInstance

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	var trans: Transform = get_parent().get_global_transform()
	var origin: Vector3 = trans.origin
	var forward: Vector3 = trans.basis.z
	forward = -forward
	var dest: Vector3 = origin + (forward * 1000)
	var mask = common.LAYER_WORLD | common.LAYER_ENTITIES
	
	var space = get_world().direct_space_state
	var result = space.intersect_ray(origin, dest)
	var finalPos: Vector3 = dest
	if result:
		# move back slightly from impact point or will draw IN the geometry
		finalPos = result.position - (forward * 0.25)
		# TODO: set forward angle to normal of impact surface
	self.global_transform.origin = finalPos
	common.debugSpawnPosition = finalPos
