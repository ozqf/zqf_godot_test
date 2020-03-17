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
	hp.connect("signal_death", self, "onDeath")

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
func _process(_delta:float):
	test_tick_motor(_delta)
	
	#_tick_ai_stack(_delta)
	pass

func test_tick_motor(_delta:float):
	if check_target() == false:
		print("mob has no target")
		return
	var move: Vector3 = motor.tick(_delta, m_body, target.global_transform.origin)
	move *= MOVE_SPEED
	var _moveResult = m_body.move_and_slide(move)
