extends "res://ents/weapons/weapon.gd"

var projectile_def = null

var m_ammoLoaded: int = 4
var m_ammoMagSize: int = 4

func init(_launchNode: Spatial):
	.init(_launchNode)

	self.m_primaryRefireTime = 0.4
	self.m_secondaryRefireTime = 0.4

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 75
	prj_def.damage = 30
	self.projectile_def = prj_def

func get_loaded_ammo():
	return m_ammoLoaded

func shoot_stakes(_count: int):
	print("Shoot " + str(_count) + " stakes")
	var def = projectile_def
	self.m_tick = self.m_primaryRefireTime
	var t = m_launchNode.get_global_transform()
	var launchDir: Vector3
	var launchEuler: Vector3

	var spreadH: float = 600
	var spreadV: float = 300
	var spreads = []
	# always one straight forward
	spreads.push_back(Vector2())

	for i in range(1, _count):
		spreads.push_back(Vector2(rand_range(-spreadH, spreadH), rand_range(-spreadV, spreadV)))

	for i in range(0, _count):
		launchDir = common.calc_forward_spread_from_basis(t.origin, t.basis, spreads[i].x, spreads[i].y)
		var prj = factory.get_free_point_projectile()
		prj.prepare_for_launch(def.teamId, def.damage, def.lifeTime)
		get_tree().get_root().add_child(prj)
		prj.launch(t.origin, launchDir, def.speed)
		prj.set_scale(Vector3(1, 1, 8))


func shoot_primary():
	shoot_stakes(1)
	m_ammoLoaded -= 1
	if (m_ammoLoaded > 0):
		m_tick = m_primaryRefireTime
	else:
		m_tick = m_primaryRefireTime * m_ammoMagSize
		m_ammoLoaded = m_ammoMagSize

func shoot_secondary():
	shoot_stakes(m_ammoLoaded)
	m_ammoLoaded = 0
	m_tick = 0.4 * m_ammoMagSize
	m_ammoLoaded = m_ammoMagSize

func _process(_delta:float):
	.common_tick(_delta)
