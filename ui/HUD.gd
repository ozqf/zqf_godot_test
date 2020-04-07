extends CanvasLayer

onready var m_debugText = $debug_text
onready var m_playerStatus = $player_status

var event_mask: int = common.EVENT_BIT_UI

func _ready():
	sys.add_observer(self)

func _process(_delta):
	# let debug text control itself
	#m_debugText.text = sys.debugText + "\n" + sys.debugCamPos
	pass

########################################
# Event response
########################################
func observe_event(_msg: String, _params):
	if _msg == "player_gained_power":
		print("HUD - Saw player get " + str(_params) + " power")
	pass

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		sys.remove_observer(self)
