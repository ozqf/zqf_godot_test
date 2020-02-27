extends Node2D

var event_mask: int = common.EVENT_BIT_GAME_STATE
onready var text = $load_percent

func _ready():
	self.hide()
	globals.add_observer(self)

func _process(_delta: float):
	var percent = globals.load_percent
	text.text = "Loading (" + str(percent) + "%)"
	pass

func observe_event(msg: String):
	if msg == "level_loading":
		self.show()
		set_process(true)
	elif msg == "level_start":
		self.hide()
		set_process(false)
