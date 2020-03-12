extends KinematicBody

const AI_STATE_IDLE:int = 0
const AI_STATE_MOVE:int = 1
const AI_STATE_ATTACK:int = 2
const AI_STATE_STUN:int = 3

var MOVE_SPEED: float = 4

onready var hp = $health
onready var weapon = $weapon
onready var motor = $motor
#onready var leftSensor = $sensors/left
#onready var rightSensor = $sensors/right

var stack = []
var target = null
var lastTargetPos: Vector3 = Vector3()
var thinkTick: float = 0

###################################################################
# Init
###################################################################
func _ready():
	# force set team
	hp.m_team = common.TEAM_MOBS

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 15
	prj_def.teamId = common.TEAM_MOBS
	prj_def.lifeTime = 3
	weapon.projectile_def = prj_def
	weapon.attackRefireTime = 2

###################################################################
# Validation
###################################################################
func check_los_to_target(_tar):
	var space = get_world().direct_space_state
	var origin = self.global_transform.origin
	origin.y += 2
	var dest = _tar.global_transform.origin
	dest.y += 2
	var mask = 1
	var result = space.intersect_ray(origin, dest, [self], mask)
	if result:
		return false
	else:
		return true

func check_target():
	target = g_ents.get_enemy_target(target, self.global_transform.origin)
	return !(target == null)

###################################################################
# State changes
###################################################################

func push_state(state: int):
	#print("Change to state " + str(state))
	stack.push_back(state)

func pop_state():
	stack.pop_back()
	var stackSize = stack.size()
	# if (stackSize > 0):
		# print("Dropped back to state " + str(stack[stackSize - 1]))
	# else:
		# print("Popped last state!")

###################################################################
# AI Ticks
###################################################################
func _process(_delta:float):
	test_tick_motor(_delta)
	
	#_tick_ai_stack(_delta)
	pass

func test_tick_motor(_delta:float):
	if check_target() == false:
		return
	var move: Vector3 = motor.tick(_delta, self, target.transform.origin)
	move *= MOVE_SPEED
	var _moveResult = move_and_slide(move)

func _tick_ai_stack(_delta: float):
	var stackLength:int = stack.size()
	# check we have an ai state
	if stack.size() == 0:
		push_state(AI_STATE_IDLE)
		stackLength = 1
	var currentState:int = stack[stackLength - 1]
	
	if currentState == AI_STATE_IDLE:
		tick_idle(_delta)
	elif currentState == AI_STATE_MOVE:
		tick_move(_delta)
	elif currentState == AI_STATE_ATTACK:
		tick_attack(_delta)
	elif currentState == AI_STATE_STUN:
		tick_stun(_delta)
	else:
		# unknown state...
		print("Unknown state " + str(currentState) + " on mob")
		pop_state()
	pass

func tick_idle(_delta: float):
	if (thinkTick <= 0):
		thinkTick = 0.2
		if check_target() == false:
			return
		# have target
		push_state(AI_STATE_MOVE)
	else:
		thinkTick -= _delta

func tick_move(_delta: float):
	if check_target() == false:
		pop_state()
	
	if thinkTick <= 0:
		thinkTick = 2
		if check_los_to_target(target) == true:
			thinkTick = 1
			push_state(AI_STATE_ATTACK)
	else:
		thinkTick -= _delta
		#motor.tick(_delta, self.transform.origin, target.transform.origin)
		move_to_attack_target(_delta)

func tick_attack(_delta:float):
	if check_target() == false:
		pop_state()
	look_at_target()
	if thinkTick <= 0:
		weapon.shoot()
		thinkTick = 2
		pop_state()
	else:
		thinkTick -= _delta

func tick_stun(_delta:float):
	if thinkTick <= 0:
		pop_state()
	else:
		thinkTick -= _delta

###################################################################
# Specific AI actions
###################################################################
func move_to_attack_target(_delta: float):
	look_at_target()
	var forward:Vector3 = -self.transform.basis.z
	var move = forward * MOVE_SPEED
	var _moveResult: Vector3 = move_and_slide(move)

func look_at_target():
	if target == null:
		return
	if check_los_to_target(target) == true:
		lastTargetPos = target.transform.origin
	lastTargetPos.y = self.transform.origin.y
	look_at(lastTargetPos, Vector3.UP)
