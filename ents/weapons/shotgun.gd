extends "res://ents/weapons/weapon.gd"

var m_numPellets: int = 12

var m_debugForward: Vector3 = Vector3()
var m_euler: Vector3 = Vector3()

var m_ammoLoaded: int = 3
var m_ammoMagSize: int = 3

var m_debugTxt: String = ""

func init(_launchNode: Spatial):
	# call base ctor
	.init(_launchNode)
	
	self.m_primaryRefireTime = 0.6
	self.m_secondaryRefireTime = 0.6

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 75
	prj_def.damage = 10
	self.m_projectile_def = prj_def
	
func get_display_name():
	return self.name

func _process(_delta:float):
	.common_tick(_delta)

func shoot_pellets(numPellets: int, spreadH: float, spreadV: float):
	var def = self.m_projectile_def
	self.m_tick = self.m_primaryRefireTime
	var t = m_launchNode.get_global_transform()
	var launchDir: Vector3
	var launchEuler: Vector3

	# TODO: Stop using this array - wasted allocs!
	var spreads = []
	# always one straight forward
	spreads.push_back(Vector2())

	# spreads.push_back(Vector2(spread, spread))
	# spreads.push_back(Vector2(-spread, -spread))
	# spreads.push_back(Vector2(spread, -spread))
	# spreads.push_back(Vector2(-spread, spread))

	for i in range(1, numPellets):
		spreads.push_back(Vector2(rand_range(-spreadH, spreadH), rand_range(-spreadV, spreadV)))

	#m_debugTxt = ""
	for i in range(0, spreads.size()):
		launchDir = common.calc_forward_spread_from_basis(t.origin, t.basis, spreads[i].x, spreads[i].y)
		.shoot_projectile_def(self.m_projectile_def, t.origin, launchDir)

func shoot_primary():
	shoot_pellets(m_numPellets, 800, 500)

func shoot_secondary():
	shoot_pellets(m_numPellets * 3, 1000, 600)
	