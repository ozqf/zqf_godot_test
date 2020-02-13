extends Spatial

var plyr_prefab_type = preload("res://prefabs3d/ent_actor_3d.tscn")

func on_world_loaded(msg: String, obj):
	var plyr = plyr_prefab_type.instance()
	plyr.transform.origin = obj.start
	add_child(plyr)
	# disable overhead camera
	# TODO: Ensure player camera takes over when spawned
	$load_camera.current = false
	print("Scene - world loaded: " + msg)
	globals.debugText = "World pos step: " + str(obj._positionStep)
	pass

func _ready():
	var node = $proc_gen_world
	print("Proc gen node: " + str(node))
	var errCode: int = node.connect("load_state", self, "on_world_loaded")
	print("Connect err: " + str(errCode))
	pass # Replace with function body.
	globals.debugText = "Make world"
