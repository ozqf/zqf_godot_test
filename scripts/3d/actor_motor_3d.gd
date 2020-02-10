extends KinematicBody

var projectilePrefab = preload("res://prefabs/Projectile.tscn")

const input_t = preload("actor_input.gd")
var input = input_t.new()

const KEYS_BIT_FORWARD = (1 << 0)
const KEYS_BIT_BACKWARD = (1 << 1)
const KEYS_BIT_LEFT = (1 << 2)
const KEYS_BIT_RIGHT = (1 << 3)

var lastMouseSample: Vector2 = Vector2(0, 0)
var physTick: float = 0

var MOUSE_SENSITIVITY: float = 0.1
var MOVE_SPEED: float = 20

func _ready():
	print("Player 3D ready")
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(_delta: float):
	if Input.is_action_pressed("attack_1"):
		print("Attack!")
	pass

func process_input(_delta: float):
	pass

func process_movement(_input, _delta: float):
	var _inputDir: Vector3 = Vector3()
	if Input.is_action_pressed("move_forward"):
		_inputDir.z -= 1
	if Input.is_action_pressed("move_backward"):
		_inputDir.z += 1
	if Input.is_action_pressed("move_left"):
		_inputDir.x -= 1
	if Input.is_action_pressed("move_right"):
		_inputDir.x += 1
	
	var _forward: Vector3 = global_transform.basis.z
	var _left: Vector3 = global_transform.basis.x

	var _velocity: Vector3 = Vector3()
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

func _physics_process(_delta: float):
	process_movement(input, _delta)
	pass

# Process mouse input via raw input events, if mouse is captured
func _input(_event: InputEvent):
	if _event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		var mMoveX: float = _event.relative.x * MOUSE_SENSITIVITY
		# flip as we want moving mouse to the right to rotate LEFT (anti-clockwise)
		mMoveX = -mMoveX
		var rotY: float = (mMoveX * globals.DEG2RAD)
		rotate_y(rotY)
	pass
