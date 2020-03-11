extends Label

func _ready():
	pass # Replace with function body.

func _process(_delta):
	var txt = globals.debugText + "\n" + globals.debugCamPos + "\n"
	txt = txt + globals.playerDebugText + "\n"
	self.text = txt
	pass
