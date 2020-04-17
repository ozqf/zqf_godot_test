extends Node

onready var m_god_hand = $god_hand

var m_weapons = []

var m_currentWeaponIndex = -1
var m_launchNode: Spatial = null

# if not -1, attempt to switch to this index next frame
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
		m_currentWeaponIndex = 0

func select_weapon_by_index(index: int):
	m_queuedWeaponSwitch = index

func _step_current_weapon_index(indexStep: int):
	var i = m_currentWeaponIndex

	i += indexStep
	print("Step weap index " + str(m_currentWeaponIndex) + " to " + str(i))
	var arrSize = m_weapons.size()
	if i >= arrSize:
		i = 0
	elif i < 0:
		i = arrSize - 1
	return i

func _cycle_selected_weapon(indexStep: int):
	assert(indexStep == 1 || indexStep == -1)
	var escape: int = 1
	while escape > 0:
		var i = _step_current_weapon_index(indexStep)
		print("Attempt to check weap index " + str(i))
		if m_weapons[i].can_equip():
			m_queuedWeaponSwitch = i
			return i
		# escape
		if escape > 10:
			print("Cannot cycle: No weapons are selectable!")
			return m_currentWeaponIndex
		escape += 1

func select_next_weapon():
	_cycle_selected_weapon(1)

func select_prev_weapon():
	_cycle_selected_weapon(-1)

func _get_current_weapon():
	if m_currentWeaponIndex < 0 || m_currentWeaponIndex >= m_weapons.size():
		return null
	return m_weapons[m_currentWeaponIndex];

# pass control inputs to the inventory.
func update_inputs(primaryOn:bool, secondaryOn:bool):
	if m_currentWeaponIndex < 0:
		return
	
	var weap = _get_current_weapon()
	# are we changing weapon?
	if m_queuedWeaponSwitch >= 0 && m_weapons[m_currentWeaponIndex].can_attack():
		# disable current weapon's input:
		weap.primaryOn = false
		weap.secondaryOn = false
		m_currentWeaponIndex = m_queuedWeaponSwitch
		print("Selected weapon " + str(m_weapons[m_currentWeaponIndex].name))
		m_queuedWeaponSwitch = -1
		# update local reference
		weap = _get_current_weapon()
	
	# update current weapon
	weap.primaryOn = primaryOn
	weap.secondaryOn = secondaryOn
