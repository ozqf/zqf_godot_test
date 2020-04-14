extends Node

onready var m_god_hand = $god_hand

var m_weapons = []

var m_currentWeaponIndex = -1
var m_launchNode: Spatial = null

const WEAPON_SWITCH_NEXT:int = -2
const WEAPON_SWITCH_PREV:int = -3

var m_queuedWeaponSwitch:int = -1

func init(launchNode: Spatial):
	m_launchNode = launchNode

# Call init before this!
func add_weapon_node(_newWeapon:Node):
	assert(_newWeapon)
	m_weapons.push_back(_newWeapon)
	print("Add weapon " + str(_newWeapon.name))
	_newWeapon.init(m_launchNode)
	if (m_currentWeaponIndex == -1):
		m_currentWeaponIndex = m_weapons.size()

func select_weapon_by_index(index: int):
	m_queuedWeaponSwitch = index

# func _queue_weapon_cycle(indexStep: int):
# 	pass

func select_next_weapon():
	pass

func select_prev_weapon():
	pass

# pass control inputs to the inventory.
func update_inputs(primaryOn:bool, secondaryOn:bool):
	if m_currentWeaponIndex < 0:
		return
	var weap = m_weapons[m_currentWeaponIndex]
	weap.primaryOn = primaryOn
	weap.secondaryOn = secondaryOn
