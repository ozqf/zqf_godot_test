extends Spatial

var plyr_prefab_type = preload("res://ents/player/ent_actor_3d.tscn")
var exit_prefab_type = preload("res://ents/info/ent_exit.tscn")

enum GameState { loading, ready, playing, over, complete }

var game_state = GameState.loading

var event_mask: int = common.EVENT_BIT_GAME_STATE

onready var proc_gen = $proc_gen_world
var plyr = null
var exit = null

func on_world_loaded(msg: String, obj):
	exit = exit_prefab_type.instance()
	exit.transform.origin = obj.end
	add_child(exit)

	plyr = plyr_prefab_type.instance()
	plyr.transform.origin = obj.start
	add_child(plyr)

	# count mobs to spawn
	var numMobs = proc_gen.mobs.size()
	print("Enemy count: " + str(numMobs))
	for i in range (0, 1):
		var p:Vector3 = proc_gen.mobs[i]
		proc_gen.spawn_mob(p.x, p.y, p.z)

	# disable overhead camera
	# TODO: Ensure player camera takes over when spawned
	$load_camera.current = false
	print("Scene - world loaded: " + msg)
	globals.debugText = "World pos step: " + str(obj._positionStep)
	globals.broadcast("level_start", common.EVENT_BIT_GAME_STATE)
	pass

func _process(_delta: float):
	globals.debugText = str(Engine.get_frames_per_second())

func _start_game():
	globals.game_root = self
	var errCode: int = proc_gen.connect("load_state", self, "on_world_loaded")
	print("Connect err: " + str(errCode))
	globals.debugText = "Make world"
	globals.broadcast("level_loading", common.EVENT_BIT_GAME_STATE)
	proc_gen.begin_load(proc_gen.asci)

func _ready():
	print("Game scene constructor")
	globals.add_observer(self)
	_start_game()
	pass

func on_level_complete():
	if game_state == GameState.complete:
		return
	game_state = GameState.complete
	plyr.queue_free()

func observe_event(msg: String):
	print("Game scene observe event " + msg)
	if msg == "level_complete":
		on_level_complete()
		

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# destructor logic
		print("Game scene destructor")
		if globals.game_root == self:
			globals.game_root = null
		globals.remove_observer(self)
		pass
