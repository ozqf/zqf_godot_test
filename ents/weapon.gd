extends Spatial

var projectile_t = preload("res://ents/projectile/ent_projectile_3d.tscn")

var on: bool = false

var attackTick: float = 0
var attackRefireTime: float = 0.1


func _process(_delta: float):
	if attackTick > 0:
		attackTick -= _delta
		return
	if on:
		attackTick = attackRefireTime
		var prj = projectile_t.instance()
		var t = get_global_transform()
		prj.prepare_for_launch(0, 20, 1)
		prj.launch(t.origin, -t.basis.z, 75, 0)
		globals.game_root.add_child(prj)
