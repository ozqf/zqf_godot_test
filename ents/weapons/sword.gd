extends "res://ents/weapons/weapon.gd"

const Enums = preload("res://Enums.gd")

const prj_throw_disc_t = preload("res://ents/projectile/prj_throw_disc.gd")

var m_showViewModel: bool = true

var m_cycleTick: float = 0
var m_cycleTotalTime: float = 0.3

var m_disc: prj_throw_disc_t
var m_volume

func init(_launchNode: Spatial):
	.init(_launchNode)
	
	self.m_primaryRefireTime = 0.3
	self.m_secondaryRefireTime = 0.3
	self.m_cycleTotalTime = 0.5

func set_disc(_newDisc: prj_throw_disc_t):
	m_disc = _newDisc

func set_melee_volume(_volumeNode):
	m_volume = _volumeNode

func shoot_primary():
	m_volume.fire()
	.shoot_primary()

func shoot_secondary():
	# do nothing, secondary is handled by the disc
	return

func _check_disc_state():
	if m_disc:
		m_disc.primaryOn = self.secondaryOn
		if m_disc.get_disc_state() != Enums.DiscState.Inactive || !m_isEquiped:
			m_showViewModel = false
			self.m_view_model.set_view_show(false)
		else:
			m_showViewModel = true
			self.m_view_model.set_view_show(true)

func _process(_delta:float):
	_check_disc_state()
	if m_showViewModel:
		.common_tick(_delta)
	if self.m_view_model:
		self.m_view_model.set_state(-1, m_tick, m_primaryRefireTime, m_cycleTick, m_cycleTotalTime)

func _physics_process(_delta: float):
	if m_disc:
		m_disc.custom_physics_process(_delta)
		pass
		
