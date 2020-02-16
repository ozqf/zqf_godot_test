extends Spatial

var plyr_prefab_type = preload("res://ents/player/ent_actor_3d.tscn")

onready var proc_gen = $proc_gen_world
var plyr

func on_world_loaded(msg: String, obj):
	plyr = plyr_prefab_type.instance()
	plyr.transform.origin = obj.start
	add_child(plyr)
	# disable overhead camera
	# TODO: Ensure player camera takes over when spawned
	$load_camera.current = false
	print("Scene - world loaded: " + msg)
	globals.debugText = "World pos step: " + str(obj._positionStep)
	pass

func _start_game():
	var errCode: int = proc_gen.connect("load_state", self, "on_world_loaded")
	print("Connect err: " + str(errCode))
	globals.debugText = "Make world"
	proc_gen.begin_load(proc_gen.asci)

func _ready():
	_start_game()
	pass
