extends "res://ents/interactor_base/spatial_interactor_base.gd"

onready var m_area: Area = $Area
onready var m_shape: CollisionShape = $Area/CollisionShape
onready var m_mesh: MeshInstance = $MeshInstance

var m_tick: int = 0
var m_on: bool = false
var m_hitDict: Dictionary = com.create_hit(100, 0.5, 0, "throw", 0, Vector3())
var m_hits = []

func _on():
	m_on = true
	m_tick = 0
	m_shape.disabled = false
	m_mesh.show()
	pass

func _off():
	m_on = false
	# disable
	m_shape.disabled = true
	m_mesh.hide()
	return

func _ready():
	_off()
	var _foo = m_area.connect("area_entered", self, "_area_entered")
	_foo = m_area.connect("body_entered", self, "_body_entered")

func _perform_hits():
	# perform hits
	m_hitDict.dir = -get_global_transform().basis.z
	for i in range(0, m_hits.size()):
		m_hits[i].interaction_take_hit(m_hitDict)
	m_hits = []

func fire():
	_on()
	pass

func _physics_process(_delta: float):
	if m_hits.size() > 0:
		_perform_hits();
	if !m_on:
		return
	if m_tick >= 1:
		_off()
		return
	m_tick += 1

func _add_hit(obj: Node):
	var interact = com.extract_interactor(obj)
	if interact:
		if !m_hits.has(interact):
			m_hits.push_back(interact)
			print("Now have " + str(m_hits.size()) + " hits")
		else:
			print("Already has hit?")

func _area_entered(_area: Area):
	_add_hit(_area)

func _body_entered(_body: Node):
	_add_hit(_body)
