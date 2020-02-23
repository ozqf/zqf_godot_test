extends KinematicBody

#var projectile_t = preload("res://ents/projectile/ent_projectile_3d.tscn")

const input_t = preload("actor_input.gd")
var input = input_t.new()

const KEYS_BIT_FORWARD = (1 << 0)
const KEYS_BIT_BACKWARD = (1 << 1)
const KEYS_BIT_LEFT = (1 << 2)
const KEYS_BIT_RIGHT = (1 << 3)

var move_mode: int = 1
var lastMouseSample: Vector2 = Vector2(0, 0)
var physTick: float = 0
var _velocity: Vector3 = Vector3()
var yaw: float = 0

onready var weapon_right = $weapon_right
onready var weapon_left = $weapon_left

#var attackTick: float = 0
#var attackRefireTime: float = 0.05

var MOUSE_SENSITIVITY: float = 0.05
var MOVE_SPEED: float = 12
var DRIVE_SPEED: float = 20
var DRIVE_ACCEL: float = 100
var TURN_RATE: float = 135

func _ready():
	print("Player 3D ready")

func _process(_delta: float):
	if globals.bGameInputActive == true and Input.is_action_pressed("attack_1"):
		weapon_right.on = true
		weapon_left.on = true
	else:
		weapon_right.on = false
		weapon_left.on = false

func process_input(_delta: float):
	pass

func process_movement(_input, _delta: float):
	var _inputDir: Vector3 = Vector3()
	if globals.bGameInputActive == true:
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
		mMoveX = 135
	if Input.is_action_pressed("ui_right"):
		mMoveX = -135
	var rotY: float = (mMoveX * globals.DEG2RAD) * _delta
	rotate_y(rotY)
	# ----
	var _forward: Vector3 = global_transform.basis.z
	var _left: Vector3 = global_transform.basis.x

	_velocity = Vector3()
	_velocity.x += _forward.x * _inputDir.z
	_velocity.y += _forward.y * _inputDir.z
	_velocity.z += _forward.z * _inputDir.z

	_velocity.x += _left.x * _inputDir.x
	_velocity.y += _left.y * _inputDir.x
	_velocity.z += _left.z * _inputDir.x

	_velocity = _velocity.normalized()
	_velocity *= MOVE_SPEED
	# TODO: No use of delta so movement is framerate sensitive?
	#_velocity *= _delta
	var _moveResult: Vector3 = move_and_slide(_velocity)

func _move_vehicle(_delta: float):
	#var _inputDir: Vector3 = Vector3()
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
	globals.debugText = "Speed: " + str(speed) + " Mul: " + str(pushMultiplier) + " dp: " + str(dp)
	if globals.bGameInputActive == true:
		if Input.is_action_pressed("move_forward"):
			#_inputDir.z -= 1
			var push: Vector3 = (-transform.basis.z * DRIVE_ACCEL) * pushMultiplier
			_velocity += push * _delta
		if Input.is_action_pressed("move_backward"):
			_velocity *= 0.95
		if Input.is_action_pressed("move_left"):
			#_inputDir.x -= 1
			#yaw += (45 * DEG2RAD) * _delta
			var rotY = (TURN_RATE * globals.DEG2RAD) * _delta
			rotate_y(rotY)
		if Input.is_action_pressed("move_right"):
			#_inputDir.x += 1
			#yaw += (45 * DEG2RAD) * _delta
			var rotY = (-TURN_RATE * globals.DEG2RAD) * _delta
			rotate_y(rotY)
	var _moveResult: Vector3 = move_and_slide(_velocity)
	pass

func _physics_process(_delta: float):
	if move_mode == 1:
		process_movement(input, _delta)
	elif move_mode == 2:
		_move_vehicle(_delta)
	#globals.debugText = str(yaw * globals.RAD2DEG)
	pass

# Process mouse input via raw input events, if mouse is captured
func _input(_event: InputEvent):
	if move_mode != 1:
		return
	if _event is InputEventMouseMotion and globals.bGameInputActive == true:
		var mMoveX: float = _event.relative.x * MOUSE_SENSITIVITY
		# flip as we want moving mouse to the right to rotate LEFT (anti-clockwise)
		mMoveX = -mMoveX
		var rotY: float = (mMoveX * globals.DEG2RAD)
		yaw += rotY
		rotate_y(rotY)
	pass
