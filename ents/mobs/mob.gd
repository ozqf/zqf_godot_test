extends KinematicBody

onready var hp = $health

onready var weapon = $weapon

var target = null

func _ready():
	# force set team
	hp.m_team = 1

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 15
	weapon.projectile_def = prj_def

func _process(_delta:float):
	target = globals.game_root.get_enemy_target(target)
	if target == null:
		return
	var tarPos:Vector3 = target.transform.origin
	tarPos.y = self.transform.origin.y
	look_at(tarPos, Vector3.UP)
	pass
