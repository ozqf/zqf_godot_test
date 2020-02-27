extends KinematicBody

onready var hp = $health

onready var weapon = $weapon

func _ready():
	# force set team
	hp.m_team = 1

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 15
	weapon.projectile_def = prj_def
