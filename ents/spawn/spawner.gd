extends Spatial

var m_spawnTime: float = 2
var m_spawnTick: float = 3

var m_children: PoolIntArray = []

func tock():
	var mob = factory.create_mob()
	var pos:Vector3 = self.transform.origin
	factory.add_to_scene_root(mob, pos)
	mob.transform.origin = pos
	var ent = mob.get_node("ent")
	m_children.push_back(ent.id)
	#print("Spawn mob " + str(ent.id) + " at " + str(pos))

func _process(_delta: float):
	if m_spawnTick <= 0:
		m_spawnTick = m_spawnTime
		tock()
	else:
		m_spawnTick -= _delta
