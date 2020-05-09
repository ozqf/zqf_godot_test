extends Spatial

onready var mesh = $mesh

var m_velocity: Vector3 = Vector3()

# these are default values but should be overridden in prepare_for_launch
var m_tickTime: float = 1
var m_teamId: int = 0
var m_damage: int = 20
var m_sourceEntId: int = 0

var m_visibilityTick: float = 0.02
 
var m_active: bool = true

func _ready():
	#print("Point prj ready")
	mesh.hide()

func _explosion_scan():
	# TODO: How does Godot want you to do single shot sphere searches...?

	# seems like they don't want you to just use a query and instead use
	# and area node that is checked for a single frame...?

	# https://docs.godotengine.org/en/3.2/classes/class_physicsdirectspacestate.html#class-physicsdirectspacestate-method-intersect-shape
	#var space = get_world().direct_space_state
	#var shape: PhysicsShapeQueryParameters = new PhysicsShapeQueryParameters()
	#space.intersect_shape()
	pass

# returns false if target was not valid to hit
func try_hit(collider):
	if collider.has_node("health"):
		var hp:Node = collider.get_node("health")
		if !hp.take_hit(m_damage, m_teamId, m_velocity.normalized()):
			# teams mismatch, ignore collision
			return false
	# else:
	# 	print("PointPrj - no health to hit")
	return true

func _move_as_ray(delta: float):
	var space = get_world().direct_space_state
	var origin = self.global_transform.origin
	#var move = m_velocity * delta
	#move *= delta
	var dest = origin + (m_velocity * delta)
	transform.origin = dest
	# reminder -1 == all bits on!
	var mask = -1
	mask &= ~common.LAYER_FENCE
	mask &= ~common.LAYER_ITEMS
	var result = space.intersect_ray(origin, dest, [self], mask)
	if result:
		# try and hit it
		if (try_hit(result.collider)):
			# hit! Spawn fx and die
			var impact = factory.create_fx_bullet_impact()
			factory.add_to_scene_root(impact, result.position)
			impact.rotation_degrees = common.calc_euler_degrees(result.normal)
			return true
		# damage target
		#print("pp hit collider: " + str(result.collider))
		# if result.collider:
		# 	if result.collider.has_node("health"):
		# 		var hp:Node = result.collider.get_node("health")
		# 		if !hp.take_hit(m_damage, m_teamId, m_velocity.normalized()):
		# 			return false
		# 	else:
		# 		print("PointPrj - no health to hit")
		# return true
	# if fell threw continue
	transform.origin = dest
	return false

func remove_self():
	m_active = false
	call_deferred("queue_free")
	pass

func _process(delta: float):
	if !m_active:
		return
	
	if _move_as_ray(delta):
		remove_self()
		return
	
	m_tickTime -= delta
	if m_tickTime <= 0:
		#print("Spawn fx at " + str(transform.origin))
		remove_self()
		return
	
	m_visibilityTick -= delta
	if m_visibilityTick < 0:
		m_visibilityTick = 9999999
		mesh.show()

# func _on_projectile_body_entered(body):
# 	if body.has_node("health"):
# 		var hp: Node = body.get_node("health")
# 		var hitDir: Vector3 = Vector3(0, 1, 0)
# 		if hp.take_hit(m_damage, m_teamId, hitDir):
# 			m_tickTime = 0
# 	else:
# 		#print("Prj hit but no hp")
# 		m_tickTime = 0

func prepare_for_launch(teamId: int, damage: int, lifeTime: float, sourceEntId: int):
	m_teamId = teamId
	m_damage = damage
	m_tickTime = lifeTime
	m_sourceEntId = sourceEntId

func launch(pos: Vector3, forward: Vector3, speed: int):
	transform.origin = Vector3();
	# orientation
	var lookPos: Vector3 = transform.origin + forward
	self.look_at(lookPos, Vector3.UP)
	#print("prj look at " + str(lookPos))
	# pos and movement
	transform.origin = pos;
	m_velocity = forward * speed

	pass
