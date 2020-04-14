extends "res://ents/weapons/weapon.gd"

var attackTick: float = 0
var attackRefireTime: float = 0.1

var projectile_def = null

var launchNode: Spatial = null;

func init(_launchNode: Spatial):
	var prj_def = factory.create_projectile_def()
	prj_def.speed = 75
	self.projectile_def = prj_def
	self.launchNode = _launchNode
	print("Inventory launch node: " + str(_launchNode))

func can_attack():
	return attackTick <= 0

func shoot():
	if !launchNode:
		print("Weapon has no launch node")
		return
	var def = projectile_def
	attackTick = attackRefireTime
	#var prj = factory.create_projectile()
	var prj = factory.create_point_projectile()
	var t = launchNode.get_global_transform()
	prj.prepare_for_launch(def.teamId, def.damage, def.lifeTime)
	prj.launch(t.origin, -t.basis.z, def.speed)
	get_tree().get_root().add_child(prj)

func _process(_delta: float):
	if attackTick > 0:
		attackTick -= _delta
		return
	if primaryOn:
		shoot()
