extends "../ent.gd"

const AI_STATE_IDLE:int = 0
const AI_STATE_MOVE:int = 1
const AI_STATE_ATTACK:int = 2
const AI_STATE_STUN:int = 3

var MOVE_SPEED: float = 4

onready var m_body = $body
onready var hp = $body/health
onready var weapon = $body/weapon
onready var motor = $body/motor

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
	hp.connect("signal_death", self, "onDeath")
	hp.connect("signal_hit", self, "onHit")

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 15
	prj_def.teamId = common.TEAM_MOBS
	prj_def.lifeTime = 3
	weapon.projectile_def = prj_def
	weapon.attackRefireTime = 2

###################################################################
# Signals
###################################################################
func onDeath():
	queue_free()
	pass

func onHit():
	
	pass
	
###################################################################
# Validation
###################################################################
func check_los_to_target(_tar):
	var space = m_body.get_world().direct_space_state
	var origin = m_body.global_transform.origin
	origin.y += 2
	var dest = _tar.global_transform.origin
	dest.y += 2
	var mask = 1
	var result = space.intersect_ray(origin, dest, [m_body], mask)
	if result:
		return false
	else:
		return true

func check_target():
	target = g_ents.get_enemy_target(target, self.global_transform.origin)
	return (target != null)

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

func test_tick_motor(_delta:float):
	if check_target() == false:
		print("mob has no target")
		return
	var move: Vector3 = motor.tick(_delta, m_body, target.get_world_position())
	move *= MOVE_SPEED
	var _moveResult = m_body.move_and_slide(move)

func tick_ai_stack(_delta: float):
	var stackSize = stack.size()
	if stackSize == 0:
		push_state(AI_STATE_IDLE)
		stackSize += 1
	
	var current:int = stack[stackSize - 1]
	if current == AI_STATE_MOVE:
		test_tick_motor(_delta)
		pass
	elif current == AI_STATE_ATTACK:
		pass
	elif current == AI_STATE_STUN:
		pass
	elif current == AI_STATE_IDLE:
		pass
	else:
		print("Unknown AI state " + str(current))
		pop_state()

###################################################################
# Frame
###################################################################
func _process(_delta:float):
	test_tick_motor(_delta)
	
	#_tick_ai_stack(_delta)
	pass
