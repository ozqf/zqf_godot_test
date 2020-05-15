extends Spatial
class_name prj_throw_disc

const Enums = preload("res://Enums.gd")

const THROW_RECALL_DELAY: float = 0.25
const RECALL_FINISH_DISTANCE: float = 2.0
const THROW_SPEED_GUIDED: float = 40.0
const THROW_SPEED: float = 75.0
const RECALL_SPEED: float = 150.0
const MAX_RECALL_TIME: float = 2.0

onready var m_worldBody: Area = $vs_world_body
onready var m_entBody: Area = $vs_world_body/vs_ent_body
onready var m_display = $vs_world_body/display
onready var m_coreDisplay = $vs_world_body/display/core
onready var m_light: OmniLight = $vs_world_body/display/light

var m_state = Enums.DiscState.Inactive
var m_effect = Enums.DiscEffect.None

var m_owner: Spatial
var m_launchNode: Spatial
var m_laserDot: Spatial
var m_lastPosition: Vector3 = Vector3()
var m_speed: float = THROW_SPEED

# Don't allow a completely instant recall
var m_recallDelayTick: float = 0
var m_startRecall: bool = false
var m_recallLerp: float = 0
var m_recallOrigin: Transform = Transform()

var m_coreSpinDegrees: float = 0

# TODO: Convert this class to use weapon base class...?
var primaryOn: bool = false
var secondaryOn: bool = false

var m_awaitControlOff: bool = false

var m_throwHitDict: Dictionary = com.create_hit(100, 0.5, 0, "throw", 0, Vector3())
var m_recallHitDict: Dictionary = com.create_hit(0, 1, 0, "recall", 0, Vector3())

func get_disc_state():
	return m_state

func teleport(_pos: Vector3):
	m_worldBody.transform.origin = _pos

func disc_init(_newOwner: Spatial, _launchNode: Spatial, _laserDotNode: Spatial):
	m_owner = _newOwner
	m_launchNode = _launchNode
	m_laserDot = _laserDotNode
	# pass owner to sub-components
	m_entBody.set_interactor(m_owner)

func _ready():
	var _foo
	_foo = m_worldBody.connect("area_entered", self, "world_area_entered")
	_foo = m_worldBody.connect("body_entered", self, "world_body_entered")
	_foo = m_entBody.connect("area_entered", self, "ent_area_entered")
	_foo = m_entBody.connect("body_entered", self, "ent_body_entered")

#######################################
# Throw/recall logic
#######################################

func _hit(_rayHitResult):
	var interact = com.extract_interactor(_rayHitResult.collider)
	if (interact):
		var hit = interact.interaction_take_hit(m_throwHitDict)
		if hit.type == Enums.InteractHitResult.Damaged:
			return 1
		elif hit.type == Enums.InteractHitResult.Killed:
			print("Disc killed!")
			return 2
		else:
			return 0
	return 1

func _move_as_ray(_delta: float):
	var space = m_worldBody.get_world().direct_space_state
	var origin = m_worldBody.transform.origin
	var dir = -m_worldBody.transform.basis.z
	var velocity = (dir * m_speed) * _delta
	var dest = origin + velocity
	var mask = com.LAYER_WORLD
	var result = space.intersect_ray(origin, dest)
	if result:
		m_throwHitDict.dir = dir
		var hitResponse = _hit(result)
		if hitResponse == 1:
			# move final position back slightly so that light
			# source at centre is not IN the surface
			var pos: Vector3 = result.position
			# pos -= (dir * 0.5)
			m_light.transform.origin = Vector3(0, 0, 0.5)
			m_worldBody.transform.origin = pos
			m_state = Enums.DiscState.Stuck
			print("Disc stopped against obj " + result.collider.name)
			return true
		elif hitResponse == 2:
			recall()
			return false
	# if fell threw continue
	m_worldBody.transform.origin = dest
	return false

func _rotate_core(_delta: float):
	m_coreSpinDegrees += 1440 * _delta
	var coreRot: Vector3 = m_coreDisplay.rotation_degrees
	coreRot.x = -m_coreSpinDegrees
	m_coreDisplay.rotation_degrees = coreRot

func _process_thrown(_delta: float):
	m_lastPosition = m_worldBody.transform.origin
	var move: Vector3 = (-m_worldBody.transform.basis.z) * THROW_SPEED
	move *= _delta
	var pos = m_worldBody.transform.origin + move
	m_worldBody.transform.origin = pos

func check_recall_start():
	if !m_startRecall:
		return
	if m_state == Enums.DiscState.Thrown:
		if m_recallDelayTick > 0:
			return
	if m_state == Enums.DiscState.Inactive:
		return
	if m_state == Enums.DiscState.Recalling:
		return
	# okay now do something
	m_state = Enums.DiscState.Recalling
	m_startRecall = false

	# TODO
	# calc speed more dynamically OR
	# lerp disc back to player so that recalling takes
	# a specific limited amount of time
	m_speed = RECALL_SPEED
	m_recallLerp = 0
	m_recallOrigin = m_worldBody.transform
	# reset light position too
	m_light.transform.origin = Vector3()

func recall():
	m_startRecall = true

func _finish_recall():
	m_state = Enums.DiscState.Inactive
	m_display.hide()
	
func _process_recall(_delta: float):
	# do a distance check as the player
	# may have moved closer!
	var originT = m_worldBody.get_transform()
	var targetT = m_owner.ent_get_transform()
	var toOwner: Vector3 = targetT.origin - m_worldBody.transform.origin
	if toOwner.length() <= RECALL_FINISH_DISTANCE:
		_finish_recall()
		return
	m_recallLerp += _delta
	if (m_recallLerp > 1):
		_finish_recall()
		return
	# position
	
	var t = originT.interpolate_with(targetT, m_recallLerp)
	m_worldBody.set_transform(t)
	# var ownerPos: Vector3 = m_owner.ent_get_world_position()
	# var selfPos: Vector3 = m_worldBody.transform.origin
	# var toOwner: Vector3 = ownerPos - selfPos
	# if toOwner.length() <= RECALL_FINISH_DISTANCE:
	# 	m_state = DiscState.Inactive
	# 	m_display.hide()
	# 	return
	# toOwner = toOwner.normalized()
	# toOwner *= (m_speed * _delta)
	# m_worldBody.transform.origin = selfPos + toOwner
	pass

func process_input(_delta: float):
	if primaryOn:
		if m_state == Enums.DiscState.Inactive:
			m_awaitControlOff = true
			var t = m_launchNode.get_global_transform() 
			launch(t.origin, -t.basis.z)
		elif m_state == Enums.DiscState.Thrown || m_state == Enums.DiscState.Stuck:
			m_awaitControlOff = true
			recall()

func turn_toward_laser(_delta: float):
	if !m_laserDot:
		return
	var result = Transform()
	var dotPos: Vector3 = m_laserDot.get_global_transform().origin
	# var curDir = -m_worldBody.transform.basis.z
	# var targetDir = (m_laserDot.transform.origin - m_worldBody.transform.origin).normalized()
	var towardLaser = m_worldBody.get_global_transform().looking_at(dotPos, Vector3.UP)
	# TODO: lerp value here is random, should really have a proper rotation rate
	var t = m_worldBody.transform.interpolate_with(towardLaser, 0.25)
	m_worldBody.set_transform(t)

func custom_physics_process(_delta: float):
	if !m_awaitControlOff:
		process_input(_delta)
	elif primaryOn == false:
		m_awaitControlOff = false

	check_recall_start()
	m_recallDelayTick -= _delta
	# Thrown
	if m_state == Enums.DiscState.Thrown:
		# animate
		_rotate_core(_delta)
		# turn if necessary
		if primaryOn:
			m_speed = THROW_SPEED_GUIDED
			turn_toward_laser(_delta)
		else:
			m_speed = THROW_SPEED
		# move
		_move_as_ray(_delta)
	# Recalling
	if m_state == Enums.DiscState.Recalling:
		_process_recall(_delta)

func launch(_pos: Vector3, _forward: Vector3):
	if m_state != Enums.DiscState.Inactive:
		print("Cannot throw yet state is "+ str(m_state))
		return
	transform.origin = Vector3()
	# reset light position too
	m_light.transform.origin = Vector3()
	m_startRecall = false
	m_state = Enums.DiscState.Thrown
	m_speed = THROW_SPEED
	m_display.show()
	m_recallDelayTick = THROW_RECALL_DELAY

	# use lookAt to change orientation
	var lookAt: Vector3 = m_worldBody.transform.origin + _forward
	m_worldBody.look_at(lookAt, Vector3.UP)
	m_worldBody.transform.origin = _pos
	m_lastPosition = _pos

#######################################
# Callbacks and Interactions
#######################################

func world_area_entered(_area: Area):
	if m_state != Enums.DiscState.Thrown:
		return
	print("World area entered: " + _area.name)
	# if (_area.collision_layer | com.LAYER_WORLD):
	# 	m_state = DiscState.Stuck
	# 	m_worldBody.transform.origin = m_lastPosition
	# 	print("Disc stuck!")

func world_body_entered(_body: PhysicsBody):
	if m_state != Enums.DiscState.Thrown:
		return
	print("World body entered: " + _body.name)
	# if (_body.collision_layer | com.LAYER_WORLD):
	# 	m_state = DiscState.Stuck
	# 	m_worldBody.transform.origin = m_lastPosition
	# 	print("Disc stuck!")

func ent_area_entered(_area: Area):
	if m_state == Enums.DiscState.Inactive:
		return
	print("Disc Ent area entered " + _area.name)
	var _interactor = com.extract_interactor(_area)
	if _interactor:
		print("Disc hit area interactor " + _interactor.name)
		if _interactor:
			var imbue = _interactor.interaction_get_imbue_effect()
			if imbue == "fire":
				print("!!!FIRE!!!")
				return false
			elif imbue == "bounce":
				print("!!!BOUNCE!!!")
				return false

func ent_body_entered(_body: PhysicsBody):
	if m_state == Enums.DiscState.Inactive:
		return
	print("Disc Ent body entered " + _body.name)
	var _interactor = com.extract_interactor(_body)
	if _interactor:
		print("Disc hit body interactor " + _interactor.name)

func get_interactor():
	return m_owner
