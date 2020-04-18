extends "res://ents/weapons/weapon.gd"

enum State { ready, firing, cycling }

var m_state = State.ready

var projectile_def = null

var m_ammoLoaded: int = 4
var m_ammoMagSize: int = 4

var m_cycleTick: float = 0
var m_cycleTotalTime: float = 0.3

var m_view_model = null

func init(_launchNode: Spatial):
	.init(_launchNode)

	self.m_primaryRefireTime = 0.3
	self.m_secondaryRefireTime = 0.3

	m_cycleTick = m_cycleTotalTime

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 75
	prj_def.damage = 30
	self.projectile_def = prj_def

func attach_view(view_stakegun):
	m_view_model = view_stakegun
	print("Stakegun got view model node " + str(m_view_model))

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
	m_tick = m_primaryRefireTime
	m_state = State.firing

func shoot_secondary():
	shoot_stakes(m_ammoLoaded)
	m_ammoLoaded = 0
	# old reload time - number of barrels - only fair if all barrels reload at once
	# m_tick = 0.4 * m_ammoMagSize
	# new reload time - rounds load one at a time anyway
	m_tick = m_primaryRefireTime
	m_state = State.firing

func _process(_delta:float):
	if m_view_model:
		m_view_model.set_loaded_ammo(m_ammoLoaded)

	if self.m_tick > 0:
		# cannot do anything - recovering from firing
		self.m_tick -= _delta
		return
	# check for firing if any rounds are loaded
	if m_ammoLoaded > 0:
		.check_triggers()
	# if all ammo loaded, no need to cycle
	if m_ammoLoaded == m_ammoMagSize:
		return
	# cycle a new round
	m_cycleTick -= _delta
	if m_cycleTick <= 0:
		m_ammoLoaded += 1
		m_cycleTick = m_cycleTotalTime

		
