extends "res://ents/interactor_base/kinematicbody_interactor_base.gd"

var m_maxhealth: int = 100
var m_health: int = 100

var m_respawning: bool = false
var m_tick: float = 0
var m_respawnTime: float = 20

func die():
	var origin = get_global_transform().origin
	#origin.y += 1
	factory.spawn_blocks_explosion(origin, 15)
	#queue_free()
	$CollisionShape.disabled = true
	hide()
	m_respawning = true

func respawn():
	m_respawning = false
	m_tick = 0
	$CollisionShape.disabled = false
	show()
	m_health = m_maxhealth

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

func _process(_delta:float):
	if m_respawning:
		m_tick += _delta
		if m_tick >= m_respawnTime:
			respawn()
