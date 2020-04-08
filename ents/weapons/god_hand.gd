extends Node

var on: bool = false

var attackTick: float = 0
var attackRefireTime: float = 0.1

var projectile_def = null

var launchNode: Spatial = null;

func can_attack():
	return attackRefireTime <= 0

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
	if on:
		shoot()
