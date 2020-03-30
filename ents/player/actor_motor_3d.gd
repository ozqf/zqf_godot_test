extends KinematicBody

# some camera positions
# high pos 0, 6, 5 angle -30, 0, 0
# low pos 0, 4, 4, angle -22.5, 0, 0

const input_t = preload("actor_input.gd")
var input = input_t.new()

const KEYS_BIT_FORWARD = (1 << 0)
const KEYS_BIT_BACKWARD = (1 << 1)
const KEYS_BIT_LEFT = (1 << 2)
const KEYS_BIT_RIGHT = (1 << 3)

const PITCH_CAP_DEGREES = 89

const KEYBOARD_TURN_DEGREES_PER_SECOND = 135

const GRAVITY_METRES_PER_SECOND = 20
const JUMP_METRES_PER_SECOND = 20

var move_mode: int = 1
var lastMouseSample: Vector2 = Vector2(0, 0)
var physTick: float = 0
var _velocity: Vector3 = Vector3()
var yaw: float = 0
var pitch: float = 0
var grounded:bool = false
var groundCollider = null

onready var head:Spatial = $display/head
onready var weapon_right = $display/head/weapon_right
onready var weapon_left = $display/head/weapon_left
onready var hp = $health
onready var bodyMesh = $display/body_mesh
onready var headMesh = $display/head/head_mesh

var MOUSE_SENSITIVITY: float = 0.15
var MOVE_SPEED: float = 12
var DRIVE_SPEED: float = 20
var DRIVE_ACCEL: float = 100
var TURN_RATE: float = 135

func _ready():
	print("Player 3D ready")
	hp.m_team = common.TEAM_PLAYER

	bodyMesh.hide()
	headMesh.hide()

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 75
	weapon_right.projectile_def = prj_def

	prj_def = factory.create_projectile_def()
	prj_def.speed = 75
	weapon_left.projectile_def = prj_def

func get_ground_check_msg():
	var txt = "Grounded: " + str(grounded) + "\n"
	if grounded:
		txt = txt + "Self " + str(self) + " vs obj " + str(groundCollider) + "\n"
		txt = txt + "Self " + self.name + " vs obj " + groundCollider.name + "\n"
	return txt

func _ground_check():
	var origin = self.transform.origin
	var dest = origin
	dest.y -= 0.2
	var mask = common.LAYER_WORLD
	var space = get_world().direct_space_state
	var result = space.intersect_ray(origin, dest, [self], mask)
	if result:
		groundCollider = result.collider
		return true
	else:
		groundCollider = null
		return false
	pass
	
func _process(_delta: float):
	grounded = _ground_check()
	if sys.bGameInputActive == true and Input.is_action_pressed("attack_1"):
		weapon_right.on = true
		weapon_left.on = true
	else:
		weapon_right.on = false
		weapon_left.on = false

func process_input(_delta: float):
	pass

func process_movement(_input, _delta: float):
	var _inputDir: Vector3 = Vector3()
	if sys.bGameInputActive == true:
		if Input.is_action_pressed("move_forward"):
			_inputDir.z -= 1
		if Input.is_action_pressed("move_backward"):
			_inputDir.z += 1
		if Input.is_action_pressed("move_left"):
			_inputDir.x -= 1
		if Input.is_action_pressed("move_right"):
			_inputDir.x += 1
	# ----
	var mMoveX: float = 0
	if Input.is_action_pressed("ui_left"):
		mMoveX = KEYBOARD_TURN_DEGREES_PER_SECOND
	if Input.is_action_pressed("ui_right"):
		mMoveX = -KEYBOARD_TURN_DEGREES_PER_SECOND
	var rotY: float = (mMoveX * common.DEG2RAD) * _delta
	rotate_y(rotY)
	# ----
	var _forward: Vector3 = global_transform.basis.z
	var _left: Vector3 = global_transform.basis.x

	var gravity: Vector3 = Vector3(0, -GRAVITY_METRES_PER_SECOND, 0)

	# clear horizontal movement
	var horiVelocity = Vector3()
	#var vertVelocity = Vector3()
	#vertVelocity.y = _velocity.y
	#_velocity.x = 0
	#_velocity.z = 0

	# apply input forces
	horiVelocity.x += _forward.x * _inputDir.z
	#horiVelocity.y += _forward.y * _inputDir.z
	horiVelocity.z += _forward.z * _inputDir.z

	horiVelocity.x += _left.x * _inputDir.x
	#horiVelocity.y += _left.y * _inputDir.x
	horiVelocity.z += _left.z * _inputDir.x
	
	horiVelocity = horiVelocity.normalized()
	horiVelocity.x *= MOVE_SPEED
	horiVelocity.z *= MOVE_SPEED

	_velocity.x = horiVelocity.x
	_velocity.z = horiVelocity.z

	if grounded:
		# apply jumping if required. Stop movement into floor
		if Input.is_action_pressed("ui_select") && _velocity.y <= 0:
			_velocity.y = JUMP_METRES_PER_SECOND
		if _velocity.y < 0:
			_velocity.y = 0
	else:
		# apply gravity
		_velocity.y += gravity.y * _delta
	
	# TODO: No use of delta so movement is framerate sensitive?
	#_velocity *= _delta
	var _moveResult: Vector3 = move_and_slide(_velocity)

func _move_vehicle(_delta: float):
	var _velNormal = _velocity.normalized()
	var speed: float = _velocity.length()
	# scale push by gap between speed and max speed
	var pushMultiplier: float = 1 - (speed / DRIVE_SPEED)
	#var dp = _velNormal.dot(-transform.basis.z)
	var dp = transform.basis.z.dot(_velNormal)
	if dp < 0:
		dp = 0
	pushMultiplier += dp
	pushMultiplier /= 2
	sys.debugText = "Speed: " + str(speed) + " Mul: " + str(pushMultiplier) + " dp: " + str(dp)
	if sys.bGameInputActive == true:
		if Input.is_action_pressed("move_forward"):
			#_inputDir.z -= 1
			var push: Vector3 = (-transform.basis.z * DRIVE_ACCEL) * pushMultiplier
			_velocity += push * _delta
		if Input.is_action_pressed("move_backward"):
			_velocity *= 0.95
		if Input.is_action_pressed("move_left"):
			var rotY = (TURN_RATE * common.DEG2RAD) * _delta
			rotate_y(rotY)
		if Input.is_action_pressed("move_right"):
			var rotY = (-TURN_RATE * common.DEG2RAD) * _delta
			rotate_y(rotY)
	var _moveResult: Vector3 = move_and_slide(_velocity)
	pass

func _physics_process(_delta: float):
	if move_mode == 1:
		process_movement(input, _delta)
	elif move_mode == 2:
		_move_vehicle(_delta)
	pass

# Process mouse input via raw input events, if mouse is captured
func _input(_event: InputEvent):
	if move_mode != 1:
		return
	if _event is InputEventMouseMotion and sys.bGameInputActive == true:
		# scale inputs by this ratio or mouse sensitivity is based on resolution!
		var scrSizeRatio: Vector2 = common.get_window_to_screen_ratio()
		# Horizontal
		var mMoveX: float = (_event.relative.x * MOUSE_SENSITIVITY * scrSizeRatio.x)
		# flip as we want moving mouse to the right to rotate LEFT (anti-clockwise)
		mMoveX = -mMoveX
		var rotY: float = (mMoveX * common.DEG2RAD)
		yaw += rotY
		# vertical
		# TODO: Uninverted mouse!
		var mMoveY: float = (_event.relative.y * MOUSE_SENSITIVITY * scrSizeRatio.y)
		var rotX: float = (mMoveY)
		pitch += rotX
		pitch = clamp(pitch, -PITCH_CAP_DEGREES, PITCH_CAP_DEGREES)
		var camRot:Vector3 = head.rotation_degrees
		camRot.x = pitch
		# apply
		rotate_y(rotY)
		# weapons are attached to head and don't need to be rotated themselves
		head.rotation_degrees = camRot
		#sys.playerDebugText = "Yaw " + str(yaw) + " Pitch: " + str(pitch)
	pass
