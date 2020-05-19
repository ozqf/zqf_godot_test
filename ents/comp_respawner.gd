extends Node

var m_tickMax:float = 20
var m_tick:float = 0
var m_respawning: bool = false

var m_owner: Node
var m_worldParent: Node = null;

func set_respawn_time(seconds: float):
	m_tickMax = seconds

func start_respawn(_owner: Node):
	m_owner = _owner
	m_tick = 0
	g_ents.add_orphan_node(m_owner, self)
	m_worldParent = m_owner.get_parent()
	print("Respawn removing self from tree")
	m_worldParent.remove_child(m_owner)
	m_respawning = true

func respawn():
	m_respawning = false
	g_ents.remove_orphan_node(m_owner)
	m_worldParent.add_child(m_owner)
	m_owner.on_respawn()

func orphan_process(_delta: float):
	if m_respawning:
		m_tick += _delta
		if m_tick >= m_tickMax:
			respawn()
