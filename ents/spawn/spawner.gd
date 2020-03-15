extends Spatial

var event_mask = common.EVENT_BIT_ENTITY_SPAWN

var m_spawnTime: float = 2
var m_spawnTick: float = 0.5

var m_max_children: int = 3
var m_children: PoolIntArray = []

func _ready():
	globals.add_observer(self)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# destructor logic
		globals.remove_observer(self)
		pass

func observer_event(_msg: String, _params):
	pass

func tock():
	var mob = factory.create_mob()
	var pos:Vector3 = self.transform.origin
	factory.add_to_scene_root(mob, pos)
	mob.transform.origin = pos
	var ent = mob.get_node("ent")
	m_children.push_back(ent.id)
	#print("Spawn mob " + str(ent.id) + " at " + str(pos))

func _process(_delta: float):
	if m_children.size() >= m_max_children:
		return
	if m_spawnTick <= 0:
		m_spawnTick = m_spawnTime
		tock()
	else:
		m_spawnTick -= _delta
