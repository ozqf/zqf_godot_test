extends Spatial

var m_owner: Spatial
var m_speed: float = 50
var m_thrown:bool = false

onready var m_body: KinematicBody = $vs_world_body

func teleport(_pos: Vector3):
	m_body.transform.origin = _pos

func set_disc_owner(_newOwner: Spatial):
	m_owner = _newOwner

func launch(_pos: Vector3, _forward: Vector3):
	print(str(m_body.transform.origin))
	#m_body.transform.origin = Vector3()

	# use lookAt to change orientation
	var lookAt: Vector3 = m_body.transform.origin + _forward
	m_body.look_at(lookAt, Vector3.UP)
	m_body.transform.origin = _pos
	self.m_thrown = true
	pass

func _ready():
	pass

func _process(_delta):
	if !m_thrown:
		return
	var move: Vector3 = (-m_body.transform.basis.z) * m_speed
	move *= _delta
	var pos = m_body.transform.origin + move
	m_body.transform.origin = pos
