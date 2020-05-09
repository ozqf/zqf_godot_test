extends Spatial

const THROW_RECALL_DELAY: float = 0.25
const RECALL_FINISH_DISTANCE: float = 2.0
const THROW_SPEED: float = 50.0
const RECALL_SPEED: float = 100.0

enum DiscState { Inactive, Thrown, Stuck, Recalling }

onready var m_worldBody: Area = $vs_world_body
onready var m_entBody: Area = $vs_world_body/vs_ent_body
onready var m_display = $vs_world_body/display

var m_state = DiscState.Inactive
var m_owner: Spatial
var m_launchNode: Spatial
var m_lastPosition: Vector3 = Vector3()

# Don't allow a completely instant recall
var m_recallDelayTick: float = 0
var m_startRecall: bool = false

var primaryOn: bool = false
var secondaryOn: bool = false

func teleport(_pos: Vector3):
	m_worldBody.transform.origin = _pos

func disc_init(_newOwner: Spatial, _launchNode: Spatial):
	m_owner = _newOwner
	m_launchNode = _launchNode

func check_recall_start():
	if !m_startRecall:
		return
	if m_state == DiscState.Thrown:
		if m_recallDelayTick > 0:
			return
	if m_state == DiscState.Inactive:
		return
	if m_state == DiscState.Recalling:
		return
	# okay now do something
	print("Recalling!")
	m_state = DiscState.Recalling
	m_startRecall = false

func recall():
	print("Recall disc")
	m_startRecall = true

func _ready():
	var _foo
	_foo = m_worldBody.connect("area_entered", self, "world_area_entered")
	_foo = m_worldBody.connect("body_entered", self, "world_body_entered")
	_foo = m_entBody.connect("area_entered", self, "ent_area_entered")
	_foo = m_entBody.connect("body_entered", self, "ent_body_entered")

func _move_as_ray(_delta: float):
	var space = get_world().direct_space_state
	var origin = self.global_transform.origin
	var move = (-m_worldBody.transform.basis.z) * (THROW_SPEED * _delta)
	#var move = m_velocity * delta
	#move *= delta
	#var dest = origin + (m_velocity * delta)
	var dest = origin + move
	m_worldBody.transform.origin = dest
	# reminder -1 == all bits on!
	var mask = common.LAYER_WORLD
	var result = space.intersect_ray(origin, dest, [self], mask)
	if result:
		m_worldBody.transform.origin = result.position
		m_state = DiscState.Stuck
		return true
	# if fell threw continue
	m_worldBody.transform.origin = dest
	return false

func _process_thrown(_delta: float):
	m_lastPosition = m_worldBody.transform.origin
	var move: Vector3 = (-m_worldBody.transform.basis.z) * THROW_SPEED
	move *= _delta
	var pos = m_worldBody.transform.origin + move
	m_worldBody.transform.origin = pos

func _process_recall(_delta: float):
	var ownerPos: Vector3 = m_owner.get_world_position()
	var selfPos: Vector3 = m_worldBody.transform.origin
	var toOwner: Vector3 = ownerPos - selfPos
	if toOwner.length() <= RECALL_FINISH_DISTANCE:
		m_state = DiscState.Inactive
		m_display.hide()
		return
	toOwner = toOwner.normalized()
	toOwner *= (RECALL_SPEED * _delta)
	m_worldBody.transform.origin = selfPos + toOwner

func _process(_delta: float):
	if primaryOn:
		pass

	check_recall_start()
	m_recallDelayTick -= _delta
	# Thrown
	if m_state == DiscState.Thrown:
		#_process_thrown(_delta)
		_move_as_ray(_delta)
	# Recalling
	if m_state == DiscState.Recalling:
		_process_recall(_delta)

func launch(_pos: Vector3, _forward: Vector3):
	if m_state != DiscState.Inactive:
		print("Cannot throw yet state is "+ str(m_state))
		return
	m_state = DiscState.Thrown
	m_display.show()
	print("Launch disc")
	print(str(m_worldBody.transform.origin))
	m_recallDelayTick = THROW_RECALL_DELAY

	# use lookAt to change orientation
	var lookAt: Vector3 = m_worldBody.transform.origin + _forward
	m_worldBody.look_at(lookAt, Vector3.UP)
	m_worldBody.transform.origin = _pos
	m_lastPosition = _pos

#######################################
# Callbacks
#######################################

func world_area_entered(_area: Area):
	if m_state != DiscState.Thrown:
		return
	print("World area entered: " + _area.name)
	if (_area.collision_layer | common.LAYER_WORLD):
		m_state = DiscState.Stuck
		m_worldBody.transform.origin = m_lastPosition
		print("Disc stuck!")

func world_body_entered(_body: PhysicsBody):
	if m_state != DiscState.Thrown:
		return
	print("World body entered: " + _body.name)
	if (_body.collision_layer | common.LAYER_WORLD):
		m_state = DiscState.Stuck
		m_worldBody.transform.origin = m_lastPosition
		print("Disc stuck!")

func ent_area_entered(_area: Area):
	if m_state == DiscState.Inactive:
		return
	print("Ent area entered " + _area.name)

func ent_body_entered(_body: PhysicsBody):
	if m_state == DiscState.Inactive:
		return
	print("Ent body entered " + _body.name)
