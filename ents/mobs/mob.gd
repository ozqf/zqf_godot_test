extends KinematicBody

onready var hp = $health

onready var weapon = $weapon

var target = null

var MOVE_SPEED: float = 6

func _ready():
	# force set team
	hp.m_team = 1

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 15
	prj_def.teamId = 1
	prj_def.lifeTime = 3
	weapon.projectile_def = prj_def
	weapon.attackRefireTime = 2
	weapon.on = true

func check_los_to_target(_tar):
	var space = get_world().direct_space_state
	var origin = self.global_transform.origin
	var dest = _tar.global_transform.origin
	var mask = 1
	var result = space.intersect_ray(origin, dest, [self], mask)
	if result:
		return false
	else:
		return true

func move(_delta: float):
	if check_los_to_target(target) == false:
		return
	var forward:Vector3 = -self.transform.basis.z
	var move = forward * MOVE_SPEED
	var _moveResult: Vector3 = move_and_slide(move)

func _process(_delta:float):
	target = globals.game_root.get_enemy_target(target)
	if target == null:
		weapon.on = false
		return
	var tarPos:Vector3 = target.transform.origin
	tarPos.y = self.transform.origin.y
	look_at(tarPos, Vector3.UP)
	move(_delta)
	pass
