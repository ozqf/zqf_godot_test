extends Camera2D

func _physics_process(_delta):
	var plyr: Node2D = get_tree().get_root().get_node("scene").get_node("Player")
	globals.debugCamPos = "Cam plyr found: " + str(plyr) + "\n"
	if plyr == null:
		globals.debugCamPos += "CamPos: No player\n"
		return
	self.position = plyr.position
	var camTxt: String = "CamPos: " + str(self.position) + " Self: " + str(self)
	globals.debugCamPos = camTxt
