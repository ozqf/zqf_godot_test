extends Spatial

# Turning based avoid AI

# top down view with sensors (forward == up)

# L___R
# |   |
# |___|

# If target to left && !leftSensor overlap - turn clockwise (left)
# If target to right && !rightSensor overlap  - turn anti-clockwise (right)
# If left sensor overlaps - turn right.
# If right sensor overlaps - turn left

# Note: Positive additions to angle turn left, negative right


var MOVE_SPEED: float = 4

# onready var leftSensor = get_parent().get_node("sensors").get_node("left")
# onready var rightSensor = get_parent().get_node("sensors").get_node("right")
onready var leftSensor = $sensors/left
onready var rightSensor = $sensors/right
#onready var parent:KinematicBody = get_parent()

var interactor = null;

var m_currentDegrees: float = 0
var m_toTargetDegrees: float = 0
var m_turnRateDegrees: float = 180

func get_interactor():
	return interactor

func no_avoid_tick(_delta:float, _self: Spatial, _targetPos: Vector3):
	var t = _self.global_transform
	var output = "== Mob avoid info ==\n"
	output = output + "SelfPos: " + str(t.origin) + "\n"
	output = output + "TarPos: " + str(_targetPos) + "\n"
	##############################################################
	# Turning function
	# apply a rotation in order to face a position
	##############################################################

	# update self angle
	
	var forward: Vector3 = t.basis.z
	var selfRadians = atan2(forward.z, forward.x)
	m_currentDegrees = rad2deg(selfRadians)
	# projected forward motion
	var moveLine: Vector2 = Vector2(cos(selfRadians), sin(selfRadians))

	# to target degrees
	var _selfPos: Vector3 = t.origin
	var dx: float = _targetPos.x - _selfPos.x
	var dz: float = _targetPos.z - _selfPos.z
	var radiansToTar: float = atan2(dz, dx)
	m_toTargetDegrees = rad2deg(radiansToTar)
	var toTar: Vector3 = Vector3(dx, _selfPos.y, dz)
	
	#var dp: float = Vector3(dx, _selfPos.y, dz).dot(_targetPos)
	var self2D: Vector2 = Vector2(_selfPos.x, _selfPos.z)
	var tar2D: Vector2 = Vector2(_targetPos.x, _targetPos.z)
	var bTarIsOnLeft = common.is_point_left_of_line2D(self2D, moveLine, tar2D)
	
	var turn: float = 0
	
	# Choose turn
	if bTarIsOnLeft:
		if leftSensor.overlaps == 1:
			# go left
			turn = m_turnRateDegrees * _delta
		else:
			# avoid - turn right
			turn = -m_turnRateDegrees * _delta
	else:
		if rightSensor.overlaps == 1:
			turn = -m_turnRateDegrees * _delta
		else:
			# avoid - turn left
			turn = m_turnRateDegrees * _delta
		
	
	# Select Turn
	var rot: Vector3 = _self.rotation_degrees
	rot.y += turn
	#if bTarIsOnLeft:
	#	#m_currentDegrees += m_turnRateDegrees * _delta
	#	rot.y += m_turnRateDegrees * _delta
	#else:
	#	#m_currentDegrees -= m_turnRateDegrees * _delta
	#	rot.y -= m_turnRateDegrees * _delta
	
	# Set rotation
	_self.rotation_degrees = rot
	
	var move:Vector3 = -forward

	output = output + str(leftSensor.overlaps) + ", " + str(rightSensor.overlaps) + "\n"
	output = output + "Current deg: " + str(m_currentDegrees) + "\n"
	output = output + "Degrees to tar " + str(m_toTargetDegrees) + "\n"
	#output = output + "DP " + str(dp) + "\n"
	output = output + "IsLeft: " + str(bTarIsOnLeft) + "\n"
	output = output + "Result: " + str(move) + "\n"
	sys.mobDebugText = output

	return move


func tick(_delta:float, _self: Spatial, _targetPos: Vector3):
	return no_avoid_tick(_delta, _self, _targetPos)
