extends "../ent.gd"

const AI_STATE_IDLE:int = 0
const AI_STATE_MOVE:int = 1
const AI_STATE_ATTACK:int = 2
const AI_STATE_ATTACK_RECOVER:int = 3
const AI_STATE_STUN:int = 4

const AI_MOVE_THINK_TIME: float = 0.5

var MOVE_SPEED: float = 0.5 #4

onready var m_body = $body
onready var hp = $body/health
onready var weapon = $body/weapon
onready var motor = $body

var stack = []
var target = null
var lastTargetPos: Vector3 = Vector3()
var m_thinkTick: float = 0

###################################################################
# Init
###################################################################
func _ready():
	# force set team
	hp.m_team = com.TEAM_MOBS
	hp.connect("signal_death", self, "onDeath")
	hp.connect("signal_hit", self, "onHit")

	motor.interactor = self

	var prj_def = factory.create_projectile_def()
	prj_def.speed = 20
	prj_def.teamId = com.TEAM_MOBS
	prj_def.lifeTime = 3
	weapon.projectile_def = prj_def
	weapon.m_primaryRefireTime = 2

###################################################################
# Signals
###################################################################
func onDeath():
	var origin = $body.get_global_transform().origin
	origin.y += 1
	factory.spawn_blocks_explosion(origin, 15)
	# for i in range(0, 15):
	# 	var debris = factory.create_debris()
	# 	var pos = origin
	# 	pos.x += rand_range(-0.5, 0.5)
	# 	pos.y += rand_range(-1, 1)
	# 	pos.z += rand_range(-0.5, 0.5)
	# 	factory.add_to_scene_root(debris, pos)
	# 	debris.throw_randomly()
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

func swap_state(state: int):
	pop_state()
	push_state(state)

###################################################################
# AI Ticks
###################################################################

# returns false if still waiting to think
func tick_think(_delta: float):
	if m_thinkTick <= 0:
		return true
	else:
		m_thinkTick -= _delta
		return false

func test_tick_motor(_delta:float):
	if check_target() == false:
		print("mob has no target")
		return
	if (m_thinkTick <= 0):
		m_thinkTick = 0.1
		swap_state(AI_STATE_ATTACK)
		return
	m_thinkTick -= _delta
	var move: Vector3 = motor.tick(_delta, m_body, target.ent_get_world_position())
	move *= MOVE_SPEED
	var _moveResult = m_body.move_and_slide(move)

func _tick_ai_stack(_delta: float):
	var stackSize = stack.size()
	if stackSize == 0:
		push_state(AI_STATE_IDLE)
		stackSize += 1
	
	var current:int = stack[stackSize - 1]
	# State machine
	if current == AI_STATE_MOVE:
		test_tick_motor(_delta)
		pass
	elif current == AI_STATE_ATTACK:
		if !tick_think(_delta):
			return
		m_thinkTick = 0.3
		weapon.shoot_primary()
		# swap to recover state
		swap_state(AI_STATE_ATTACK_RECOVER)
	elif current == AI_STATE_ATTACK_RECOVER:
		if !tick_think(_delta):
			return
		pop_state()
	elif current == AI_STATE_STUN:
		if !tick_think(_delta):
			return
		pop_state()
	elif current == AI_STATE_IDLE:
		var target = check_target()
		if !target:
			return
		m_thinkTick = 2
		push_state(AI_STATE_MOVE)
	else:
		print("Unknown AI state " + str(current))
		pop_state()

###################################################################
# Frame
###################################################################
func _process(_delta:float):
	#test_tick_motor(_delta)
	
	_tick_ai_stack(_delta)
	pass
