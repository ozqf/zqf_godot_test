extends Spatial

onready var m_rotator = $rotator
var m_stakes = []
var m_stakeIndex = 0

var m_max_ammo: int = 4
var m_loaded_ammo: int = 4

# var state = {
# 	"ammo_loaded": 4,
# 	"ammo_max": 4,
# 	"cycleTick": 0.0,
# 	"cycleMax": 0.3
# }

func _ready():
	m_stakes.push_back($rotator/stake_0)
	m_stakes.push_back($rotator/stake_1)
	m_stakes.push_back($rotator/stake_2)
	m_stakes.push_back($rotator/stake_3)

func set_max_ammo(_ammo: int):
	m_max_ammo = _ammo
	m_loaded_ammo = _ammo

func set_slide_position(stake: Spatial, slide_lerp: float):
	var trans = stake.get_transform()
	var pos = trans.origin
	# pos.z = 2 * (1 - slide_lerp)
	pos.z = 2 * slide_lerp
	stake.set_translation(pos)
	#trans.origin = pos

# Second attempt, adding stakes loading forward... doesn't work yet!
func set_state_2(_ammo: int, _rotateTime: float, _rotateMax: float, _loadTime: float, _loadMax: float):
	# if _ammo == m_loaded_ammo:
	# 	# don't apply unncessary changes
	# 	return
	m_loaded_ammo = _ammo

	# slide round forward lerp
	# var slide_lerp: float
	# slide_lerp = 1 - (_loadTime / _loadMax)
	# slide_lerp = _loadTime / _loadMax
	# if _loadTime > 0:
	# 	slide_lerp = _loadTime / _loadMax
	# else:
	# 	slide_lerp = 1
	
	for i in range(0, m_stakes.size()):
		#set_slide_position(m_stakes[i], slide_lerp)
		m_stakes[i].hide()
	for i in range(0, _ammo):
		m_stakes[i].show()
	var stepDegrees:float = float(360) / float(m_max_ammo)
	var numSteps = m_max_ammo - m_loaded_ammo
	var partialStep: float
	#if m_loaded_ammo == m_max_ammo:
	#	partialStep = 0
	#else:
	# partialStep = (_rotateTime / _rotateMax) * stepDegrees
	partialStep = (_loadTime / _loadMax) * stepDegrees
	
	var desiredRollDegrees: float = stepDegrees  * numSteps
	var _loadPercent = _loadTime / _loadMax
	desiredRollDegrees -= partialStep

	sys.weaponDebugText = "view_stakegun: " + str(m_loaded_ammo) + " of " + str(m_max_ammo) + "\n"
	sys.weaponDebugText += "Degrees " + str(desiredRollDegrees)
	sys.weaponDebugText += " time: " + str(_rotateTime) + "/" + str(_rotateMax) + "\n"
	#sys.weaponDebugText += "Slide time " + str(slide_lerp) + "\n"
	#print(self.name + " loaded " + str(m_loaded_ammo) + " degrees: " + str(desiredRollDegrees))
	var bodyRot:Vector3 = self.rotation_degrees
	bodyRot.z = desiredRollDegrees
	self.rotation_degrees = bodyRot

# simple state setup
func set_state(_ammo: int, _rotateTime: float, _rotateMax: float, _loadTime: float, _loadMax: float):
	m_loaded_ammo = _ammo

	for i in range(0, m_stakes.size()):
		m_stakes[i].hide()
	for i in range(0, _ammo):
		m_stakes[i].show()
	var stepDegrees:float = float(360) / float(m_max_ammo)
	var numSteps = m_max_ammo - m_loaded_ammo
	var partialStep: float
	
	partialStep = (_loadTime / _loadMax) * stepDegrees
	
	var desiredRollDegrees: float = stepDegrees  * numSteps
	var _loadPercent = _loadTime / _loadMax
	desiredRollDegrees -= partialStep

	# sys.weaponDebugText = "view_stakegun: " + str(m_loaded_ammo) + " of " + str(m_max_ammo) + "\n"
	# sys.weaponDebugText += "Degrees " + str(desiredRollDegrees)
	# sys.weaponDebugText += " time: " + str(_rotateTime) + "/" + str(_rotateMax) + "\n"
	
	var bodyRot:Vector3 = self.rotation_degrees
	bodyRot.z = desiredRollDegrees
	self.rotation_degrees = bodyRot
