extends "res://ents/weapons/weapon.gd"

var m_cycleTick: float = 0
var m_cycleTotalTime: float = 0.3

func init(_launchNode: Spatial):
	.init(_launchNode)

	self.m_primaryRefireTime = 1
	self.m_secondaryRefireTime = 1

func _process(_delta:float):
	.common_tick(_delta)
	if self.m_view_model:
		self.m_view_model.set_state(-1, m_tick, m_primaryRefireTime, m_cycleTick, m_cycleTotalTime)