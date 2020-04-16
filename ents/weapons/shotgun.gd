extends "res://ents/weapons/weapon.gd"

var projectile_def = null

var m_numPellets: int = 12

var m_debugForward: Vector3 = Vector3()
var m_euler: Vector3 = Vector3()

func init(_launchNode: Spatial):
	# call base ctor
	.init(_launchNode)
	
	self.m_primaryRefireTime = 0.5
	self.m_secondaryRefireTime = 0.5

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 75
	prj_def.damage = 10000
	self.projectile_def = prj_def
	
func get_display_name():
	return self.name

func _process(_delta:float):
	.common_tick(_delta)

	var t = m_launchNode.get_global_transform()
	var sourceForward: Vector3 = -t.basis.z
	var pitchDegrees: float = common.calc_pitch_degrees3D(sourceForward)
	var yawDegrees: float = common.calc_yaw_degrees3D(sourceForward)
	m_euler = common.calc_flat_plane_radians(sourceForward)
	m_euler.x *= common.RAD2DEG
	m_euler.y *= common.RAD2DEG
	var launch:Vector3 = common.calc_euler_to_forward3D_1(m_euler.x, m_euler.y)

	m_debugForward = launch

	sys.weaponDebugText = ""
	sys.weaponDebugText += "Forward: " + str(sourceForward) + "\n"
	sys.weaponDebugText += "Pitch/Yaw: " + str(pitchDegrees) + "/" + str(yawDegrees) + "\n"
	sys.weaponDebugText += "Flat angles: " + str(m_euler) + "\n"
	sys.weaponDebugText += "Launch: " + str(launch) + "\n"


func shoot_primary():
	if !m_launchNode:
		print("Weapon has no launch node")
		return
	# print("Shotgun fire " + str(m_numPellets) + " pellets")
	var def = projectile_def
	self.m_tick = self.m_primaryRefireTime
	var t = m_launchNode.get_global_transform()
	var launchDir: Vector3
	var launchEuler: Vector3
	
	for i in range(0, m_numPellets):
		launchEuler = m_euler
		launchEuler.x += rand_range(-5, 5)
		launchEuler.y += rand_range(-10, 10)

		launchDir = common.calc_euler_to_forward3D_1(launchEuler.x, launchEuler.y)
		
		var prj = factory.create_point_projectile()
		prj.prepare_for_launch(def.teamId, def.damage, def.lifeTime)
		prj.launch(t.origin, launchDir, def.speed)
		get_tree().get_root().add_child(prj)
