extends Spatial

func on_world_loaded():
	print("Scene - world loaded")
	# disable overhead camera
	# TODO: Ensure player camera takes over when spawned
	#$load_camera.current = false
	pass

func _ready():
	#var node = $proc_gen_world
	#print("Proc gen node: " + str(node))
	#var errCode: int = node.connect("load_State", self, "on_world_loaded")
	#print("Connect err: " + str(errCode))
	pass # Replace with function body.
