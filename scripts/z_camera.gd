extends Node2D

func _ready():
	pass # Replace with function body.

func _process(delta):
	#Globals.set("currentCamera", self)
	# Get the globals singleton
	var mPos = get_global_mouse_position ()
	var globals = get_node("/root/globals")
	pass
