extends Spatial

var projectile_t = preload("res://ents/projectile/ent_projectile_3d.tscn")

var on: bool = false

var attackTick: float = 0
var attackRefireTime: float = 0.05


func _process(_delta: float):
	if attackTick > 0:
		attackTick -= _delta
		return
	if on:
		attackTick = attackRefireTime
		var prj = projectile_t.instance()
		var t = get_global_transform()
		prj.launch(t.origin, -t.basis.z, 100, 0)
		globals.game_root.add_child(prj)
