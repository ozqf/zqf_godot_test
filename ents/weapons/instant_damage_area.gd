extends "res://ents/interactor_base/spatial_interactor_base.gd"

onready var m_area: Area = $Area
onready var m_shape: CollisionShape = $Area/CollisionShape
onready var m_mesh: MeshInstance = $MeshInstance

var m_tick: int = 0

func _on():
	m_tick = 0
	m_shape.disabled = false
	#m_area.visible = false
	m_mesh.show()
	pass

func _off():
	m_shape.disabled = true
	#m_area.visible = true
	m_mesh.hide()
	pass

func _ready():
	_off()
	var _foo = m_area.connect("area_entered", self, "_area_entered")
	_foo = m_area.connect("body_entered", self, "_body_entered")

func fire():
	print("Fire melee")
	_on()
	pass

func _physics_process(_delta: float):
	if m_tick >= 1:
		_off()
		return
	m_tick += 1

func _area_entered(_area: Area):
	print("Melee hit area")
	pass

func _body_entered(_body: Node):
	print("Melee hit body")
	pass
