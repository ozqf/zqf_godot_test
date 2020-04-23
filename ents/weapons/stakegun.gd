extends "res://ents/weapons/weapon.gd"

enum State { ready, firing, cycling }

var m_state = State.ready

var projectile_def = null

var m_ammoLoaded: int = 4
var m_ammoMagSize: int = 4

var m_cycleTick: float = 0
var m_cycleTotalTime: float = 0.35

func init(_launchNode: Spatial):
	.init(_launchNode)

	self.m_primaryRefireTime = 0.2
	self.m_secondaryRefireTime = 0.2

	m_cycleTick = m_cycleTotalTime

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 100
	prj_def.damage = 40
	self.projectile_def = prj_def

# func attach_view(view_stakegun):
# 	self.m_view_model = view_stakegun
# 	print("Stakegun got view model node " + str(self.m_view_model))

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
		prj.prepare_for_launch(def.teamId, def.damage, def.lifeTime, ownerId)
		get_tree().get_root().add_child(prj)
		prj.launch(t.origin, launchDir, def.speed)
		prj.set_scale(Vector3(1.5, 1.5, 12))


func shoot_primary():
	shoot_stakes(1)
	m_ammoLoaded -= 1
	m_tick = m_primaryRefireTime
	m_state = State.firing
	m_cycleTick = 0

func shoot_secondary():
	shoot_stakes(m_ammoLoaded)
	m_ammoLoaded = 0
	# old reload time - number of barrels - only fair if all barrels reload at once
	# m_tick = 0.4 * m_ammoMagSize
	# new reload time - rounds load one at a time anyway
	m_tick = m_primaryRefireTime
	m_state = State.firing
	m_cycleTick = 0

func _process(_delta:float):
	if self.m_view_model:
		self.m_view_model.set_state(m_ammoLoaded, m_tick, m_primaryRefireTime, m_cycleTick, m_cycleTotalTime)

	if self.m_tick > 0:
		# cannot do anything - recovering from firing
		self.m_tick -= _delta
		m_cycleTick = 0
		return
	# check for firing if any rounds are loaded
	if m_ammoLoaded > 0:
		.check_triggers()
	# if all ammo loaded, no need to cycle
	if m_ammoLoaded == m_ammoMagSize:
		return
	# cycle a new round
	m_cycleTick += _delta
	if m_cycleTick >= m_cycleTotalTime:
		m_ammoLoaded += 1
		if m_ammoLoaded < m_ammoMagSize:
			# begin again
			m_cycleTick = 0

		
