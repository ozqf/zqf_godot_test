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

const MOUSE_SENSITIVITY: float = 0.15
const MOVE_SPEED: float = 15.0
const MOVE_ACCELERATION: float = 150.0
const MOVE_PUSH_STRENGTH: float = 0.2
const GROUND_FRICTION: float = 10.0
const MOVE_AIR_MULTIPLIER: float = 0.3
const GRAVITY_METRES_PER_SECOND = 25.0
const JUMP_METRES_PER_SECOND = 10.0

# Slower movement for testing
#const MOUSE_SENSITIVITY: float = 0.15
#const MOVE_SPEED: float = 10.0 #17.0
#const MOVE_ACCELERATION: float = 50.0 # 200.0
#const MOVE_PUSH_STRENGTH: float = 0.2
#const GROUND_FRICTION: float = 4.0 #8.0
#const MOVE_AIR_MULTIPLIER: float = 0.3
# const GRAVITY_METRES_PER_SECOND = 10.0 # 30.0
# const JUMP_METRES_PER_SECOND = 6 #10.0

const DRIVE_SPEED: float = 20.0
const DRIVE_ACCEL: float = 100.0
const TURN_RATE: float = 135.0

# Set from external source
# will be passed around for interactions
var interactionParent = null;

var move_mode: int = 1
var lastMouseSample: Vector2 = Vector2(0, 0)
var physTick: float = 0

var _velocity: Vector3 = Vector3()
var lastMove: Vector3 = Vector3()
var lastDelta: float = 1 / 60
var nextPushVelocity: Vector3 = Vector3()
var nextThrowVelocity: Vector3 = Vector3()

var yaw: float = 0
var pitch: float = 0
var grounded:bool = false
var airJumps: int = 1
var maxAirJumps: int = 1
var groundCollider = null

var writeDebug: bool = false
var calcVelTxt: String = ""

onready var head:Spatial = $display/head
onready var weapon_right = $display/head/weapon_right
onready var weapon_left = $display/head/weapon_left
onready var hp = $health
onready var bodyMesh = $display/body_mesh
onready var headMesh = $display/head/head_mesh

func _ready():
	print("Player 3D ready")
	hp.m_team = common.TEAM_PLAYER

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

func _cast_ground_ray(origin: Vector3):
	#var origin = self.get_global_transform().origin
	origin.y += 0.1
	var dest = origin
	dest.y -= 0.15
	var mask = common.LAYER_WORLD
	var space = get_world().direct_space_state
	var result = space.intersect_ray(origin, dest, [self], mask)
	sys.debugDraw.add_line(origin, dest)
	if result:
		groundCollider = result.collider
		return true
	else:
		groundCollider = null
		return false

func _ground_check():
	var p = self.get_global_transform().origin
	#if _cast_ground_ray(p):
	#	return true
	if _cast_ground_ray(Vector3(p.x - 0.4, p.y, p.z)):
		return true
	if _cast_ground_ray(Vector3(p.x + 0.4, p.y, p.z)):
		return true
	
	if _cast_ground_ray(Vector3(p.x, p.y, p.z - 0.4)):
		return true
	if _cast_ground_ray(Vector3(p.x, p.y, p.z + 0.4)):
		return true
	return false
	
func _process(_delta: float):
	grounded = _ground_check()
	# if sys.bGameInputActive == true and Input.is_action_pressed("attack_1"):
	# 	weapon_right.primaryOn = true
	# 	weapon_left.primaryOn = true
	# else:
	# 	weapon_right.primaryOn = false
	# 	weapon_left.primaryOn = false

func process_input(_delta: float):
	pass

func throw(_throwVelocityPerSecond: Vector3):
	#print("Throw actor3D - " + str(_throwVelocityPerSecond))
	# Add the throw to be applied during the next tick
	#nextPushVelocity += _throwVelocityPerSecond
	nextThrowVelocity = _throwVelocityPerSecond
	# reset air jumps
	airJumps = maxAirJumps

func teleport(pos: Vector3):
	#print("Actor teleport - " + str(pos))
	transform.origin = pos
	lastMove = Vector3()

func get_interactor():
	return interactionParent
	
# Combine current velocity with desired input
func calc_final_velocity(
	_current: Vector3,
	accelDir: Vector3,
	_maxMoveSpeed: float,
	_delta: float,
	_onGround:bool):

	var result:Vector3 = Vector3()
	var inputOn: bool = (accelDir.length() > 0)
	
	###############################################################
	# Quake style

	# Calculate current velocity per second,
	# (after avoiding divide by zero...)
	# reconstruct it by taking the last position change
	# scaled back by last delta. Appears to be accurate to
	# 4 decimal places.
	var previousVelocity: Vector3
	if lastDelta != 0:
		previousVelocity = lastMove * (1 / lastDelta)
		# clear vertical movement, it is handled separately via gravity!
		previousVelocity.y = 0
	else:
		previousVelocity = Vector3()
	
	var previousSpeed: float = previousVelocity.length()
	# Stop dead if slow enough
	if previousSpeed < 0.001:
		previousVelocity = Vector3()
		previousSpeed = 0
	
	var acceleration:float = MOVE_ACCELERATION
	# friction
	if _onGround && previousSpeed > 0 && (inputOn == false || previousSpeed > _maxMoveSpeed):
		var drop: float = previousSpeed * GROUND_FRICTION * _delta
		var frictionScalar: float = max(previousSpeed - drop, 0) / previousSpeed
		previousVelocity.x *= frictionScalar
		previousVelocity.z *= frictionScalar

	if !_onGround:
		acceleration *= MOVE_AIR_MULTIPLIER

	# Check applying this push would not exceed the maximum run speed
	# If necessary truncale the velocity so the vector projection does not
	# exceed maximum run speed
	var projectionVelocityDot: float = accelDir.dot(previousVelocity)
	#var projectionVelocityDot: float = previousVelocity.dot(accelDir)
	var accelerationMagnitude: float = acceleration * _delta

	if projectionVelocityDot + accelerationMagnitude > _maxMoveSpeed:
		accelerationMagnitude = _maxMoveSpeed - projectionVelocityDot
	
	# accelerationMagnitude can be pushed into negative
	# so Avoid actively reducing speed!
	if accelerationMagnitude < 0:
		accelerationMagnitude = 0
	
	# apply scaled acceleration
	result.x = previousVelocity.x + (accelDir.x * accelerationMagnitude)
	result.z = previousVelocity.z + (accelDir.z * accelerationMagnitude)
	
	var printFullVectors: bool = true
	
	if writeDebug:
		calcVelTxt = "-- Calc Velocity --\n"
		if printFullVectors:
			calcVelTxt += "Last Move " + str(lastMove.length()) + ": " + str(lastMove) + "\n"
			calcVelTxt += "Last velocity " + str(previousVelocity.length()) + ": " + str(previousVelocity) + "\n"
			calcVelTxt += "Push " + str(accelDir.length()) + ":" + str(accelDir) + "\n"
		else:
			calcVelTxt += "Last Move " + str(lastMove) + "\n"
			calcVelTxt += "Last velocity " + str(previousVelocity.length()) + "\n"
			calcVelTxt += "Push " + str(accelDir.length()) + "\n"
		calcVelTxt += "Last DT " + str(lastDelta) + "\n"
		calcVelTxt += "ProjectionVel Dot: " + str(projectionVelocityDot) + "\n"
		calcVelTxt += "Accel mag: " + str(accelerationMagnitude) + "\n"
		calcVelTxt += "Final Horizontal move: " + str(result) + "\n"
	return result

func process_movement(_input, _delta: float):
	var _inputDir: Vector3 = Vector3()
	# -------------------------------
	# movement
	if sys.bGameInputActive == true:
		if Input.is_action_pressed("move_forward"):
			_inputDir.z -= 1
		if Input.is_action_pressed("move_backward"):
			_inputDir.z += 1
		if Input.is_action_pressed("move_left"):
			_inputDir.x -= 1
		if Input.is_action_pressed("move_right"):
			_inputDir.x += 1
		# -------------------------------
		# Keyboard turning
		# Horizontal
		var mMoveX: float = 0
		if Input.is_action_pressed("ui_left"):
			mMoveX = KEYBOARD_TURN_DEGREES_PER_SECOND
		if Input.is_action_pressed("ui_right"):
			mMoveX = -KEYBOARD_TURN_DEGREES_PER_SECOND
		#var rotY: float = (mMoveX * common.DEG2RAD) * _delta
		#rotate_y(rotY)
		yaw += mMoveX * _delta
		
		var mMoveY: float = 0
		# Vertical
		if Input.is_action_pressed("ui_up"):
			mMoveY = KEYBOARD_TURN_DEGREES_PER_SECOND
		if Input.is_action_pressed("ui_down"):
			mMoveY = -KEYBOARD_TURN_DEGREES_PER_SECOND
		pitch += mMoveY * _delta
	
	# ----
	var _forward: Vector3 = global_transform.basis.z
	var _left: Vector3 = global_transform.basis.x

	var gravity: Vector3 = Vector3(0, -GRAVITY_METRES_PER_SECOND, 0)

	# clear horizontal movement
	var runPush = Vector3()
	#var vertVelocity = Vector3()
	#vertVelocity.y = _velocity.y
	#_velocity.x = 0
	#_velocity.z = 0

	# apply input forces
	runPush.x += _forward.x * _inputDir.z
	#runPush.y += _forward.y * _inputDir.z
	runPush.z += _forward.z * _inputDir.z

	runPush.x += _left.x * _inputDir.x
	#runPush.y += _left.y * _inputDir.x
	runPush.z += _left.z * _inputDir.x
	
	runPush = runPush.normalized()
	# runPush.x *= MOVE_SPEED
	# runPush.z *= MOVE_SPEED
	#runPush.x *= MOVE_PUSH_STRENGTH
	#runPush.z *= MOVE_PUSH_STRENGTH

	var horizontal: Vector3 = calc_final_velocity(_velocity, runPush, MOVE_SPEED, _delta, grounded)
	
	_velocity.x = horizontal.x
	_velocity.z = horizontal.z

	# _velocity.x = runPush.x
	# _velocity.z = runPush.z

	if grounded:
		# Clear any negative speed
		if _velocity.y < 0:
			_velocity.y = 0
		# reset air jumps
		airJumps = maxAirJumps
		# apply jumping if required. Stop movement into floor
		if Input.is_action_pressed("ui_select") && _velocity.y <= 0:
			_velocity.y = JUMP_METRES_PER_SECOND
	# check for air jump
	elif airJumps > 0 && Input.is_action_just_pressed("ui_select"):
			#print("Air jump!")
			_velocity.y = JUMP_METRES_PER_SECOND
			airJumps -= 1
	else:
		# apply gravity
		_velocity.y += gravity.y * _delta
	
	if nextThrowVelocity.length_squared() > 0:
		_velocity = nextThrowVelocity
		#print("Apply throw - " + str(_velocity))
		nextThrowVelocity = Vector3()
	# Apply and then clear any saved throw interactions
	if nextPushVelocity.length_squared() > 0:
		_velocity += nextPushVelocity
		#print("Apply push - " + str(_velocity))
		nextPushVelocity = Vector3()
		if _velocity.y > 0:
			grounded = false
	
	# TODO: No use of delta so movement is framerate sensitive?
	#_velocity *= _delta
	var prevPosition: Vector3 = self.get_global_transform().origin
	var _moveResult: Vector3 = move_and_slide(_velocity)
	if writeDebug:
		# NOTE: Assumes that calcVelTxt was reset earlier this frame above
		calcVelTxt += "Final Velocity " + str(_velocity.length()) + ": " + str(_velocity) + "\n"
	lastMove = self.get_global_transform().origin - prevPosition
	lastDelta = _delta

# TODO: Move test guff to separate class
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

func _apply_rotations(_delta: float):
	var bodyRot:Vector3 = self.rotation_degrees
	bodyRot.y = yaw
	self.rotation_degrees = bodyRot

	pitch = clamp(pitch, -PITCH_CAP_DEGREES, PITCH_CAP_DEGREES)
	var camRot:Vector3 = head.rotation_degrees
	camRot.x = pitch
	head.rotation_degrees = camRot

func _physics_process(_delta: float):
	if move_mode == 1:
		_apply_rotations(_delta)
		process_movement(input, _delta)
	elif move_mode == 2:
		_move_vehicle(_delta)
	pass

# Process mouse input via raw input events, if mouse is captured
func _input(_event: InputEvent):
	if move_mode != 1:
		return
	if _event is InputEventMouseMotion and sys.bGameInputActive == true:
		# NOTE: Apply input to pitch/yaw values. But do not
		# set spatial rotations yet.

		# scale inputs by this ratio or mouse sensitivity is based on resolution!
		var scrSizeRatio: Vector2 = common.get_window_to_screen_ratio()

		# Horizontal
		var mMoveX: float = (_event.relative.x * MOUSE_SENSITIVITY * scrSizeRatio.x)
		# flip as we want moving mouse to the right to rotate LEFT (anti-clockwise)
		mMoveX = -mMoveX
		var rotY: float = (mMoveX * common.DEG2RAD)
		yaw += mMoveX

		# vertical
		# TODO: Uninverted mouse!
		var mMoveY: float = (_event.relative.y * MOUSE_SENSITIVITY * scrSizeRatio.y)
		pitch += mMoveY
	pass
