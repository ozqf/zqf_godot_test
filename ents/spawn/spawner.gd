extends Spatial

var spawnTime: float = 2
var spawnTick: float = 11111111

func tock():
	var mob = factory.create_mob()
	var pos:Vector3 = self.transform.origin
	factory.add_to_scene_root(mob, pos)
	mob.transform.origin = pos
	print("Spawn mob at " + str(pos))

func _process(_delta: float):
	if spawnTick <= 0:
		spawnTick = spawnTime
		tock()
	else:
		spawnTick -= _delta
