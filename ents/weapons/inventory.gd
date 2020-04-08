extends Node

onready var m_god_hand = $god_hand

var m_currentWeapon = null;
var m_launchNode: Spatial = null

func init(launchNode: Spatial):
	m_launchNode = launchNode
	
	var prj_def = factory.create_projectile_def()
	prj_def.speed = 75
	m_god_hand.projectile_def = prj_def
	m_god_hand.launchNode = m_launchNode
	print("Inventory launch node: " + str(launchNode))
	m_currentWeapon = m_god_hand

func _process(_delta: float):
	if sys.bGameInputActive == true and Input.is_action_pressed("attack_1"):
		m_currentWeapon.on = true
	else:
		m_currentWeapon.on = false
