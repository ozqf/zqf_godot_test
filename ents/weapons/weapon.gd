# Base class for weapons
extends Node

var primaryOn: bool = false
var secondaryOn: bool = false

var ownerId: int = 0

var m_launchNode: Spatial = null;

var m_tick: float = 0
var m_primaryRefireTime: float = 0
var m_secondaryRefireTime: float = 0

var m_view_model = null
var m_isEquiped = null

# If this weapon fires a projectile setup def here
var m_projectile_def = null

func init(_launchNode: Spatial):
	m_launchNode = _launchNode

func attach_view(view_model_node):
	self.m_view_model = view_model_node

func set_equipped(flag: bool):
	m_isEquiped = flag
	
	if m_view_model:
		if m_isEquiped:
			m_view_model.show()
		else:
			m_view_model.hide()

func can_attack():
	return self.m_tick <= 0

func can_equip():
	return true

func shoot_primary():
	m_tick = m_primaryRefireTime

func shoot_secondary():
	m_tick = m_secondaryRefireTime
	
func get_display_name():
	return self.name

func get_loaded_ammo():
	return -1

func get_total_ammo():
	return -1

##############################
# Sub-class sandbox functions
# not all weapons will use
##############################

# check inputs and shoot
func check_triggers():
	if primaryOn:
		if !m_launchNode:
			print(self.name + " has no launch node")
			return
		shoot_primary()
	elif secondaryOn:
		if !m_launchNode:
			print(self.name + " has no launch node")
			return
		shoot_secondary()

# simplest update type. If ready, check input
func common_tick(_delta:float):
	if self.m_tick > 0:
		self.m_tick -= _delta
		return
	check_triggers()

# Returns the projectile launched if additional stuff is required
func shoot_projectile_def(def, origin: Vector3, forward: Vector3):
	if !def:
		print("Weapon has no projectile def")
		return
	self.m_tick = self.m_primaryRefireTime
	var prj = factory.get_free_point_projectile()
	#var t = launchNode.get_global_transform()
	prj.prepare_for_launch(def.teamId, def.damage, def.lifeTime, ownerId)
	get_tree().get_root().add_child(prj)
	prj.launch(origin, forward, def.speed)
	return prj
