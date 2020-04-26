extends "res://ents/weapons/weapon.gd"

###############################
# Debugging weapon
#  primary: insta-kill attack
#  secondary: spawn monsters
###############################

const MODE_DESTROY: String = "Destroy"
const MODE_CREATE: String = "Create"

var m_mode: String = "Destroy"

func init(_launchNode: Spatial):
	# call base ctor
	.init(_launchNode)
	
	self.m_primaryRefireTime = 0.1
	self.m_secondaryRefireTime = 0.5
	
	var prj_def = factory.create_projectile_def()
	prj_def.speed = 75
	prj_def.damage = 10000
	self.m_projectile_def = prj_def

func shoot_primary():
	if !m_launchNode:
		print("Weapon has no launch node")
		return
	var def = self.m_projectile_def
	self.m_tick = self.m_primaryRefireTime
	#var prj = factory.create_projectile()
	var prj = factory.get_free_point_projectile()
	var t = m_launchNode.get_global_transform()
	prj.prepare_for_launch(def.teamId, def.damage, def.lifeTime, ownerId)
	get_tree().get_root().add_child(prj)
	prj.launch(t.origin, -t.basis.z, def.speed)

func shoot_secondary():
	self.m_tick = self.m_secondaryRefireTime
	console.execute("spawn mob")
	pass

func _process(_delta: float):
	.common_tick(_delta)
