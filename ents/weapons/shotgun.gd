extends "res://ents/weapons/weapon.gd"

var projectile_def = null

var m_numPellets: int = 10

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
	sys.weaponDebugText = "Pitch/Yaw: " + str(pitchDegrees) + "/" + str(yawDegrees) + "\n"
	var flatAngles:Vector3 = common.calc_flat_plane_angles(sourceForward)
	sys.weaponDebugText += "Flat angles: " + str(flatAngles * common.RAD2DEG) + "\n"


func shoot_primary():
	if !m_launchNode:
		print("Weapon has no launch node")
		return
	# print("Shotgun fire " + str(m_numPellets) + " pellets")
	var def = projectile_def
	self.m_tick = self.m_primaryRefireTime
	var t = m_launchNode.get_global_transform()
	var sourceForward: Vector3 = -t.basis.z
	#var pitchDegrees: float = common.calc_pitch_degrees3D(sourceForward)
	#pitchDegrees = 0
	#var yawDegrees: float = common.calc_yaw_degrees3D(sourceForward)
	# var launchPitchDegrees: float
	# var launchYawDegrees: float
	var forward:Vector3 = Vector3()
	#forward = common.calc_euler_to_forward3D(pitchDegrees, yawDegrees)
	# print("Launch pitch/yaw: " + str(pitchDegrees) + "/" + str(yawDegrees))
	# print("\tForward: ", str(forward))
	var euler: Vector3 = common.calc_flat_plane_angles(sourceForward)
	forward = common.calc_euler_to_forward3D(euler.x * common.RAD2DEG, euler.y * common.RAD2DEG)
	
	for i in range(0, m_numPellets):
		# launchPitchDegrees = pitchDegrees
		# launchYawDegrees = yawDegrees
		# launchPitchDegrees += rand_range(-5, 5)
		# launchYawDegrees += rand_range(-5, 5)
		#print("Launch pitch/yaw: " + str(launchPitchDegrees) + "/" + str(launchYawDegrees))
		# https://stackoverflow.com/questions/1568568/how-to-convert-euler-angles-to-directional-vector
		#forward = common.calc_euler_to_forward3D(launchPitchDegrees, launchYawDegrees)

		var prj = factory.create_point_projectile()
		prj.prepare_for_launch(def.teamId, def.damage, def.lifeTime)
		prj.launch(t.origin, forward, def.speed)
		get_tree().get_root().add_child(prj)
