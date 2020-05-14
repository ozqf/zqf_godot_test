extends "res://ents/interactor_base/spatial_interactor_base.gd"

onready var m_area: Area = $Area
onready var m_shape: CollisionShape = $Area/CollisionShape
onready var m_mesh: MeshInstance = $MeshInstance

var m_tick: int = 0
var m_on: bool = false
var m_hitDict: Dictionary = common.create_hit_dict(100, 0.5, 0, "throw", 0, Vector3())
var m_hits = []

func _on():
	m_on = true
	m_tick = 0
	m_shape.disabled = false
	#m_area.visible = false
	m_mesh.show()
	m_hits = []
	pass

func _off():
	m_on = false
	# perform hits
	m_hitDict.dir = -get_global_transform().basis.z
	print("Perform " + str(m_hits.size()) + " hits")
	for i in range(0, m_hits.size()):
		m_hits[i].interaction_take_hit(m_hitDict)
	# disable
	m_shape.disabled = true
	#m_area.visible = true
	m_mesh.hide()
	return

func _ready():
	_off()
	var _foo = m_area.connect("area_entered", self, "_area_entered")
	_foo = m_area.connect("body_entered", self, "_body_entered")

func fire():
	print("Fire melee")
	_on()
	pass

func _physics_process(_delta: float):
	if !m_on:
		return
	if m_tick >= 1:
		_off()
		return
	m_tick += 1

func _add_hit(obj: Node):
	var interact = common.extract_interactor(obj)
	if interact:
		print("Try add hit")
		if !m_hits.has(interact):
			m_hits.push_back(interact)
			print("Now have " + str(m_hits.size()) + " hits")
		else:
			print("Already has hit?")

func _area_entered(_area: Area):
	print("Melee hit area")
	_add_hit(_area)

func _body_entered(_body: Node):
	print("Melee hit body")
	_add_hit(_body)
