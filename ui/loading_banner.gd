extends Sprite

var event_mask: int = common.EVENT_BIT_GAME_STATE

func _ready():
	globals.add_observer(self)

func observe_event(msg: String):
	if msg == "level_loading":
		self.show()
	elif msg == "level_start":
		self.hide()