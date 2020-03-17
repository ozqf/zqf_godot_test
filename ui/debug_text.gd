extends Label

func _ready():
	pass # Replace with function body.

func _process(_delta):
	var txt = sys.debugText + "\n" + sys.debugCamPos + "\n"
	txt = txt + sys.playerDebugText + "\n"
	txt = txt + sys.mobDebugText + "\n"
	self.text = txt
	pass
