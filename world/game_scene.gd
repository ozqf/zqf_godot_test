extends Spatial

var plyr_prefab_type = preload("res://ents/player/ent_actor_3d.tscn")
var exit_prefab_type = preload("res://ents/info/ent_exit.tscn")

enum GameState { loading, ready, playing, over, complete }

var game_state = GameState.loading

var event_mask: int = common.EVENT_BIT_GAME_STATE | common.EVENT_BIT_ENTITY_SPAWN

onready var proc_gen = $proc_gen_world
var plyr = null
var exit = null

func get_enemy_target(_target):
	# no player in the game?
	if plyr == null:
		return null
	return plyr

func on_world_loaded(msg: String, obj):
	exit = exit_prefab_type.instance()
	exit.transform.origin = obj.end
	add_child(exit)

	var player = plyr_prefab_type.instance()
	player.transform.origin = obj.start
	add_child(player)

	# count mobs to spawn
	var numMobs = proc_gen.mobs.size()
	print("Enemy count: " + str(numMobs))
	var spawnCount = 1 # for testing
	#var spawnCount = numMobs
	for i in range (0, spawnCount):
		var p:Vector3 = proc_gen.mobs[i]
		proc_gen.spawn_mob(p.x, p.y, p.z)

	# disable overhead camera
	# TODO: Ensure player camera takes over when spawned
	$load_camera.current = false
	print("Scene - world loaded: " + msg)
	sys.debugText = "World pos step: " + str(obj._positionStep)
	sys.broadcast(common.EVENT_LEVEL_START, null, common.EVENT_BIT_GAME_STATE)
	pass

func _start_game():
	sys.game_root = self
	if proc_gen == null:
		print("Start game - no proc gen")
		sys.broadcast(common.EVENT_LEVEL_START, null, common.EVENT_BIT_GAME_STATE)
		return
	var errCode: int = proc_gen.connect("load_state", self, "on_world_loaded")
	print("Connect err: " + str(errCode))
	sys.debugText = "Make world"
	sys.broadcast(common.EVENT_LEVEL_LOADING, null, common.EVENT_BIT_GAME_STATE)
	proc_gen.begin_load(proc_gen.asci)

func _ready():
	print("Game scene constructor")
	sys.add_observer(self)
	_start_game()
	pass

func on_level_complete():
	if game_state == GameState.complete:
		return
	game_state = GameState.complete
	plyr.queue_free()

func observe_event(msg: String, _obj):
	print("Game scene observe event " + msg)
	if msg == common.EVENT_LEVEL_COMPLETE:
		on_level_complete()
	if (msg == common.EVENT_PLAYER_SPAWN):
		plyr = _obj
	if (msg == common.EVENT_PLAYER_DIED):
		if plyr == _obj:
			plyr = null
		

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# destructor logic
		print("Game scene destructor")
		if sys.game_root == self:
			sys.game_root = null
		sys.remove_observer(self)
		pass
