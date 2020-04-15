extends "res://ents/weapons/weapon.gd"

var projectile_def = null

func init(_launchNode: Spatial):
	# call base ctor
	.init(_launchNode)
	
	self.m_primaryRefireTime = 0.1
	self.m_secondaryRefireTime = 0

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 75
	self.projectile_def = prj_def

func can_attack():
	return self.m_tick <= 0

func shoot_primary():
	if !m_launchNode:
		print("Weapon has no launch node")
		return
	var def = projectile_def
	self.m_tick = self.m_primaryRefireTime
	var prj = factory.create_point_projectile()
	var t = m_launchNode.get_global_transform()
	prj.prepare_for_launch(def.teamId, def.damage, def.lifeTime)
	prj.launch(t.origin, -t.basis.z, def.speed)
	get_tree().get_root().add_child(prj)

func _process(_delta: float):
	.common_tick(_delta)
