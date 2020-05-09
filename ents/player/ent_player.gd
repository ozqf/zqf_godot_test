extends "../ent.gd"

###############################################
# Component Nodes
###############################################
onready var m_body = $body
onready var m_hp = $body/health

onready var m_fpsCamera = $body/display/head/fps_camera_mount/camera
onready var m_debugCamera = $body/display/head/debug_camera_mount/camera

onready var m_bodyMesh = $body/display/body_mesh
onready var m_headMesh = $body/display/head/head_mesh

onready var m_weaponCentre: Spatial = $body/display/head/weapon_centre
onready var m_weaponRight = $body/display/head/weapon_right
onready var m_weaponLeft = $body/display/head/weapon_left

onready var m_inventory = $inventory

var m_disc = null

###############################################
# Members
###############################################
var writeDebug: bool = true


###############################################
# Init
###############################################
func _init_weapons():
	# must be added in slot order!
	m_inventory.add_weapon_node($inventory/sword)
	m_inventory.add_weapon_node($inventory/stakegun)
	m_inventory.add_weapon_node($inventory/shotgun)
	m_inventory.add_weapon_node($inventory/blaster)
	m_inventory.add_weapon_node($inventory/rocket_launcher)
	m_inventory.add_weapon_node($inventory/god_hand)

	m_inventory.select_weapon_by_index(0)

	# link up weapons and their display models:
	var view_default = $body/display/head/weapon_right_model/view_weapon_default
	var view_stakegun = $body/display/head/weapon_right_model/view_stakegun
	var view_shotgun = $body/display/head/weapon_right_model/view_shotgun
	var view_sword = $body/display/head/weapon_right_model/view_sword

	view_default.hide()
	view_stakegun.hide()
	view_shotgun.hide()
	view_sword.hide()

	$inventory/stakegun.attach_view(view_stakegun)
	$inventory/shotgun.attach_view(view_shotgun)
	$inventory/sword.attach_view(view_sword)
	$inventory/blaster.attach_view(view_default)
	$inventory/rocket_launcher.attach_view(view_default)

func _ready():
	# base class call
	print("Ent Player type " + str(self) + " ready")
	print("  set launch node: " + str(m_weaponCentre))
	
	###############################################
	# Init inventory
	###############################################

	# Create disc
	m_disc = factory.create_disc_projectile()
	g_ents.add_scene_object(m_disc)
	m_disc.set_disc_owner(self)

	# Assuming Id is already set here!
	m_inventory.init(m_weaponCentre, self.id)
	_init_weapons()

	#m_hp.ent = self
	m_hp.m_team = common.TEAM_PLAYER
	m_hp.connect("signal_death", self, "on_death")
	m_hp.connect("signal_hit", self, "on_hit")
	
	m_fpsCamera.current = true
	m_debugCamera.current = false
	m_bodyMesh.hide()
	m_headMesh.hide()
	# attach to body for physical interactions
	m_body.interactionParent = self

	sys.broadcast(common.EVENT_PLAYER_SPAWN, self, common.EVENT_BIT_ENTITY_SPAWN)

func toggle_cameras():
	if m_fpsCamera.current == true:
		#switch to third person cam
		m_fpsCamera.current = false
		m_debugCamera.current = true
		m_bodyMesh.show()
		m_headMesh.show()
	else:
		# switch to fps cam
		m_fpsCamera.current = true
		m_debugCamera.current = false
		m_bodyMesh.hide()
		m_headMesh.hide()

func _process(_delta:float):
	if Input.is_action_just_pressed("toggle_camera"):
		toggle_cameras()
	
	# Update inventory inputs
	var primaryOn: bool = false
	var secondaryOn: bool = false
	if sys.bGameInputActive:

		# update the disc too
		if Input.is_action_just_pressed("throw_a"):
			print("Throw A")
			var t = m_weaponCentre.get_global_transform()
			m_disc.launch(t.origin, -t.basis.z)

		primaryOn = Input.is_action_pressed("attack_1")
		secondaryOn = Input.is_action_pressed("attack_2")
		if Input.is_action_just_pressed("next_weapon"):
			m_inventory.select_next_weapon()
		if Input.is_action_just_pressed("prev_weapon"):
			m_inventory.select_prev_weapon()
		if Input.is_action_just_pressed("slot_1"):
			m_inventory.select_weapon_by_index(0)
		if Input.is_action_just_pressed("slot_2"):
			m_inventory.select_weapon_by_index(1)
		if Input.is_action_just_pressed("slot_3"):
			m_inventory.select_weapon_by_index(2)
		if Input.is_action_just_pressed("slot_4"):
			m_inventory.select_weapon_by_index(3)
		if Input.is_action_just_pressed("slot_5"):
			m_inventory.select_weapon_by_index(4)

	m_inventory.update_inputs(primaryOn, secondaryOn)

	if writeDebug:
		var selfPos = global_transform.origin
		var bodyPos = m_body.global_transform.origin
		var txt = m_body.get_ground_check_msg()
		#txt += "Player ent pos " + str(selfPos) + "\nPlayer body pos: " + str(bodyPos) + "\n"
		txt += "Pitch " + str(m_body.m_pitch) + " yaw " + str(m_body.m_yaw) + "\n"
		txt += "Velocity " + str(m_body._velocity) + "\n"
		txt += m_body.calcVelTxt
		sys.playerDebugText = txt
	pass
	sys.hud.check_changed("ammo", m_inventory.get_loaded_ammo())

func get_world_position():
	return self.m_body.global_transform.origin

########################################
# Signals
########################################
func on_hit():
	print("Player hit")

func on_death():
	print("Player death")

########################################
# Interactions functions
########################################
func interaction_throw(_throwVelocityPerSecond: Vector3):
	#print("Throw player!")
	m_body.throw(_throwVelocityPerSecond)

func interaction_teleport(_pos: Vector3):
	#print("Teleport player!")
	m_body.teleport(_pos)

func interaction_give(_itemName: String, _amount: int):
	if _itemName == "damage":
		print("Player taking " + str(_amount) + " of damage powerup")
		sys.broadcast(common.EVENT_PLAYER_GAINED_POWER, _amount, common.EVENT_BIT_UI)
		return _amount
	return 0
