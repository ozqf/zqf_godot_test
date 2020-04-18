extends Spatial

onready var m_rotator = $rotator
var m_stakes = []
var m_stakeIndex = 0

var m_max_ammo: int = 4
var m_loaded_ammo: int = 4

func _ready():
	m_stakes.push_back($rotator/stake_0)
	m_stakes.push_back($rotator/stake_1)
	m_stakes.push_back($rotator/stake_2)
	m_stakes.push_back($rotator/stake_3)

func set_max_ammo(ammo: int):
	m_max_ammo = ammo
	m_loaded_ammo = ammo

func set_loaded_ammo(ammo: int):
	if ammo == m_loaded_ammo:
		# don't apply unncessary changes
		return
	m_loaded_ammo = ammo

	for i in range(0, m_stakes.size()):
		m_stakes[i].hide()
	for i in range(0, ammo):
		m_stakes[i].show()
	var stepDegrees:float = float(360) / float(m_max_ammo)
	var numSteps = m_max_ammo - m_loaded_ammo
	var desiredRollDegrees: float = stepDegrees * numSteps
	print(self.name + " loaded " + str(m_loaded_ammo) + " degrees: " + str(desiredRollDegrees))
	var bodyRot:Vector3 = self.rotation_degrees
	bodyRot.z = desiredRollDegrees
	self.rotation_degrees = bodyRot