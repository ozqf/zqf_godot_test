extends Label

func _ready():
	pass # Replace with function body.

func _process(delta):
	self.text = globals.debugText + "\n" + globals.debugCamPos
	pass
