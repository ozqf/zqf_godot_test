extends Spatial

var primaryOn: bool = false
var ownerId: int = 0

var m_tick: float = 0
var m_primaryRefireTime: float = 0.1

var projectile_def = null

func can_attack():
	return m_primaryRefireTime <= 0

func shoot_primary():
	var def = projectile_def
	m_tick = m_primaryRefireTime
	#var prj = factory.create_projectile()
	var prj = factory.get_free_point_projectile()
	var t = get_global_transform()
	prj.prepare_for_launch(def.teamId, def.damage, def.lifeTime, ownerId)
	prj.launch(t.origin, -t.basis.z, def.speed)
	get_tree().get_root().add_child(prj)

func _process(_delta: float):
	if m_tick > 0:
		m_tick -= _delta
		return
	if primaryOn:
		shoot_primary()
