extends "res://ents/interactor_base/kinematicbody_interactor_base.gd"

var m_worldParent: Node = null;

var m_maxhealth: int = 100
var m_health: int = 100

var m_respawning: bool = false
var m_tick: float = 0
var m_respawnTime: float = 20

func die():
	var origin = get_global_transform().origin
	#origin.y += 1
	factory.spawn_blocks_explosion(origin, 15)
	m_respawning = true

	# remove from tree
	g_ents.add_updatable_orphan_node(self)
	m_worldParent = get_parent()
	print("Crate removing self from tree")
	m_worldParent.remove_child(self)

func respawn():
	m_respawning = false
	m_tick = 0
	m_health = m_maxhealth

	g_ents.remove_updatable_orphan_node(self)
	m_worldParent.add_child(self)

func interaction_take_hit(_hitData: Dictionary):
	if m_health <= 0:
		return com.create_hit_response(Enums.InteractHitResult.None)
	
	m_health -= _hitData.dmg
	if (m_health <= 0):
		print("CRATE died to type " + _hitData.type)
		die()
		return com.create_hit_response(Enums.InteractHitResult.Killed)
	return com.create_hit_response(Enums.InteractHitResult.Damaged)
	#return com.create_hit_response(Enums.InteractHitResult.None)

# func _process(_delta:float):
# 	if m_respawning:
# 		m_tick += _delta
# 		if m_tick >= m_respawnTime:
# 			respawn()

func orphan_process(_delta: float):
	if m_respawning:
		m_tick += _delta
		if m_tick >= m_respawnTime:
			respawn()