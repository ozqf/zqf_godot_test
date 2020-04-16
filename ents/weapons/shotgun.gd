extends "res://ents/weapons/weapon.gd"

var projectile_def = null

var m_numPellets: int = 10

var m_debugForward: Vector3 = Vector3()

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
	var flatAngles:Vector3 = common.calc_flat_plane_radians(sourceForward)
	flatAngles.x *= common.RAD2DEG
	flatAngles.y *= common.RAD2DEG
	var launch:Vector3 = common.calc_euler_to_forward3D_1(flatAngles.x, flatAngles.y)

	m_debugForward = launch

	sys.weaponDebugText = ""
	sys.weaponDebugText += "Forward: " + str(sourceForward) + "\n"
	sys.weaponDebugText += "Pitch/Yaw: " + str(pitchDegrees) + "/" + str(yawDegrees) + "\n"
	sys.weaponDebugText += "Flat angles: " + str(flatAngles) + "\n"
	sys.weaponDebugText += "Launch: " + str(launch) + "\n"


func shoot_primary():
	if !m_launchNode:
		print("Weapon has no launch node")
		return
	# print("Shotgun fire " + str(m_numPellets) + " pellets")
	var def = projectile_def
	self.m_tick = self.m_primaryRefireTime
	var t = m_launchNode.get_global_transform()
	# var sourceForward: Vector3 = -t.basis.z
	# var forward:Vector3 = Vector3()
	# var euler: Vector3 = common.calc_flat_plane_radians(sourceForward)
	#forward = common.calc_euler_to_forward3D_1(euler.x * common.RAD2DEG, euler.y * common.RAD2DEG)
	
	for i in range(0, m_numPellets):
		#print("Launch pitch/yaw: " + str(launchPitchDegrees) + "/" + str(launchYawDegrees))
		# https://stackoverflow.com/questions/1568568/how-to-convert-euler-angles-to-directional-vector
		
		var prj = factory.create_point_projectile()
		prj.prepare_for_launch(def.teamId, def.damage, def.lifeTime)
		prj.launch(t.origin, m_debugForward, def.speed)
		get_tree().get_root().add_child(prj)
