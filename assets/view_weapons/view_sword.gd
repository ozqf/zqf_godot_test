extends "res://assets/view_weapons/view_weapon.gd"

onready var position_0_node: Spatial = $position_0
onready var position_1_node: Spatial = $position_1
onready var m_mesh: Spatial = $mesh

func _ready():

	pass

func set_state(_ammo: int, _rotateTime: float, _rotateMax: float, _loadTime: float, _loadMax: float):
	var lerpPercent = _rotateTime / _rotateMax
	sys.weaponDebugText = "Sword time " + str(lerpPercent)
	
	var trans_0 = position_0_node.get_transform()
	var trans_1 = position_1_node.get_transform()
	var scale = m_mesh.scale
	var trans_current = trans_0.interpolate_with(trans_1, lerpPercent)
	m_mesh.set_transform(trans_current)
	#trans_0.interpolate_with(trans_1, lerpPercent)
