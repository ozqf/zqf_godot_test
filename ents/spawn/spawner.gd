extends "../ent.gd"

var m_spawnTime: float = 2
var m_spawnTick: float = 0.5
var m_active: bool = false

var m_max_children: int = 3
var m_children: PoolIntArray = []

func _ready():
	event_mask = common.EVENT_BIT_ENTITY_SPAWN | common.EVENT_BIT_ENTITY_TRIGGER
	sys.add_observer(self)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# destructor logic
		sys.remove_observer(self)
		pass

func observe_event(_msg: String, _params):
	if _msg == common.EVENT_MOB_DIED:
		var numChildren = m_children.size()
		for i in range(0, numChildren):
			if int(m_children[i]) == int(_params.id):
				m_children.remove(i)
				return
		pass
	if _msg == common.EVENT_ENTITY_TRIGGER:
		if entName == _params && m_active == false:
			print("Spawner " + entName + " triggered")
			m_active = true

func tock():
	var mob = factory.create_mob()
	var pos:Vector3 = self.transform.origin
	factory.add_to_scene_root(mob, pos)
	mob.transform.origin = pos
	m_children.push_back(mob.id)
	#print("Spawn mob " + str(ent.id) + " at " + str(pos))

func _process(_delta: float):
	if !m_active:
		return
	if m_children.size() >= m_max_children:
		return
	if m_spawnTick <= 0:
		m_spawnTick = m_spawnTime
		tock()
	else:
		m_spawnTick -= _delta
