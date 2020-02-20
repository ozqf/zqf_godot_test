extends Control

var event_mask: int = 1

func _ready():
	self.hide()
	globals.add_observer(self)

func observe_event(msg: String):
	if msg == "level_complete":
		self.show()
	elif msg == "level_state":
		self.hide()
