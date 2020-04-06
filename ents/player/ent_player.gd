extends "../ent.gd"

onready var body = $body
onready var hp = $body/health

onready var cam1 = $body/display/head/camera
onready var cam2 = $body/display/head/camera2

onready var bodyMesh = $body/display/body_mesh
onready var headMesh = $body/display/head/head_mesh


func _ready():
	# base class call
	print("Ent Player type " + str(self) + " ready")
	hp.ent = self
	#._ready()
	sys.broadcast(common.EVENT_PLAYER_SPAWN, self, common.EVENT_BIT_ENTITY_SPAWN)
	cam1.current = true
	cam2.current = false
	bodyMesh.hide()
	headMesh.hide()

	# attach to body for physical interactions
	body.interactionParent = self

func toggle_cameras():
	if cam1.current == true:
		#switch to third person cam
		cam1.current = false
		cam2.current = true
		bodyMesh.show()
		headMesh.show()
	else:
		# switch to fps cam
		cam1.current = true
		cam2.current = false
		bodyMesh.hide()
		headMesh.hide()

func _process(_delta:float):
	if Input.is_action_just_pressed("toggle_camera"):
		toggle_cameras()

	var selfPos = global_transform.origin
	var bodyPos = body.global_transform.origin
	#var onGround = body.get_ground_check_msg()
	var txt = body.get_ground_check_msg()
	# var txt = body.get_ground "Grounded " + str(onGround) + "\n"
	#if body.groundCollider != null:
	#	txt = txt + "Ground Obj: " + str(body.name) + "\n"
	txt = txt + "Player ent pos " + str(selfPos) + "\nPlayer body pos: " + str(bodyPos) + "\n"
	txt += "Velocity " + str(body._velocity) + "\n"
	txt += body.calcVelTxt
	sys.playerDebugText = txt
	pass

func get_world_position():
	return self.body.global_transform.origin

########################################
# Interactions functions
########################################
func interaction_throw(_throwVelocityPerSecond: Vector3):
	#print("Throw player!")
	body.throw(_throwVelocityPerSecond)

func interaction_teleport(_pos: Vector3):
	#print("Teleport player!")
	body.teleport(_pos)

func interaction_give(_itemName: String, _amount: int):
	print("Player taking " + str(_amount) + " of damage powerup")
	return _amount
