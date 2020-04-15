extends "res://ents/weapons/weapon.gd"

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
