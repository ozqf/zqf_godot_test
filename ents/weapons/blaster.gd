extends "res://ents/weapons/weapon.gd"

func init(_launchNode: Spatial):
	# call base ctor
	.init(_launchNode)
	
	self.m_primaryRefireTime = 0.1
	self.m_secondaryRefireTime = 0

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 75
	prj_def.damage = 10
	self.m_projectile_def = prj_def

func can_attack():
	return self.m_tick <= 0

func shoot_primary():
	var t = m_launchNode.get_global_transform()
	.shoot_projectile_def(self.m_projectile_def, t.origin, -t.basis.z)

func _process(_delta: float):
	.common_tick(_delta)
