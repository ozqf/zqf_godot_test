extends "res://ents/ent.gd"

var m_lerp: float = 0

onready var m_a: Spatial = $a
onready var m_b: Spatial = $b
onready var m_body = $body

var m_origin: Spatial
var m_dest: Spatial

var m_travelTime: float = 12

func _ready():
	m_origin = m_a
	m_dest = m_b

func _process(_delta: float):
	#print(str(m_lerp))
	m_lerp += (_delta / m_travelTime)
	if m_lerp > 1:
		m_lerp = 1
	var originT: Transform = m_origin.get_global_transform()
	var destT: Transform = m_dest.get_global_transform()
	var t = originT.interpolate_with(destT, m_lerp)
	m_body.global_transform = t
	if m_lerp == 1:
		m_lerp = 0
		var temp = m_origin
		m_origin = m_dest
		m_dest = temp
	pass

