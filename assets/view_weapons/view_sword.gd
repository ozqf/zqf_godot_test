extends "res://assets/view_weapons/view_weapon.gd"

onready var position_0_node: Spatial = $position_0
onready var position_1_node: Spatial = $position_1
onready var position_2_node: Spatial = $position_2
onready var m_mesh: Spatial = $mesh

func _ready():
	position_0_node.hide()
	position_1_node.hide()
	position_2_node.hide()
	pass

func set_view_show(show: bool):
	self.visible = show

func set_state(_ammo: int, _rotateTime: float, _rotateMax: float, _loadTime: float, _loadMax: float):
	var lerpPercent = _rotateTime / _rotateMax
	sys.weaponDebugText = "Sword time " + str(lerpPercent)
	
	var trans_0 = position_0_node.get_transform()
	var trans_1 = position_1_node.get_transform()
	var trans_2 = position_2_node.get_transform()
	var scale = m_mesh.scale
	#var trans_current = trans_0.interpolate_with(trans_1, lerpPercent)
	var trans_current
	if lerpPercent < 0:
		# inert, snap to default
		trans_current = trans_0
	else:
		# swinging, lerp
		trans_current = trans_2.interpolate_with(trans_0, lerpPercent)
	m_mesh.set_transform(trans_current)
	#trans_0.interpolate_with(trans_1, lerpPercent)
