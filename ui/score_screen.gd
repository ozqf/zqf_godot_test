extends CanvasLayer

onready var container: Control = $screen_container
var event_mask: int = common.EVENT_BIT_GAME_STATE

func _ready():
	container.hide()
	sys.add_observer(self)

func observe_event(msg: String, _obj):
	if msg == "level_complete":
		container.show()
	elif msg == "level_start":
		container.hide()
