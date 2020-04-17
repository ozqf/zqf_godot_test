extends Node

var primaryOn: bool = false
var secondaryOn: bool = false

var m_launchNode: Spatial = null;

var m_tick: float = 0
var m_primaryRefireTime: float = 0
var m_secondaryRefireTime: float = 0

func init(_launchNode: Spatial):
	m_launchNode = _launchNode
	pass

func can_attack():
	return self.m_tick <= 0

func can_equip():
	return true

func shoot_primary():
	m_tick = m_primaryRefireTime

func shoot_secondary():
	m_tick = m_secondaryRefireTime
	
func get_display_name():
	return self.name

func get_loaded_ammo():
	return -1

func get_total_ammo():
	return -1

func common_tick(_delta:float):
	if self.m_tick > 0:
		self.m_tick -= _delta
		return
	if primaryOn:
		if !m_launchNode:
			print(self.name + " has no launch node")
			return
		shoot_primary()
	elif secondaryOn:
		if !m_launchNode:
			print(self.name + " has no launch node")
			return
		shoot_secondary()
