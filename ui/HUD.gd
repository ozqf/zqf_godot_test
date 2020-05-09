extends CanvasLayer

const HUD_MESSAGE_FADE_TIME: int = 2

class NumberChange:
	var name: String
	var value: float

class StringChange:
	var name: String
	var value: String
	
onready var m_debugText = $debug_text
onready var m_playerStatus = $player_status

onready var m_healthValue = $player_status/health/health_value
onready var m_ammoValue = $player_status/ammo/ammo_value

onready var m_hud_message: Label = $hud_message
onready var m_hud_message_calls: int = 0
onready var m_hud_message_tick: float = 0

var numbers = {
	"health": 0,
	"ammo": 0
}

var event_mask: int = common.EVENT_BIT_UI

var m_numberChanges = []
var m_stringChanges = []

func _ready():
	m_hud_message.text = ""
	sys.add_observer(self)

func _process(_delta):
	# let debug text control itself
	#m_debugText.text = sys.debugText + "\n" + sys.debugCamPos

	# process number changes
	for i in range(0, m_numberChanges.size()):
		var change = m_numberChanges[i]
		if change.name == "ammo":
			numbers["ammo"] = change.value
			m_ammoValue.text = str(change.value)
	m_numberChanges.clear()

	# hide hud message
	if m_hud_message_tick <= 0:
		m_hud_message.text = ""
		m_hud_message_tick = 99999
	else:
		m_hud_message_tick -= _delta

func check_changed(name: String, value: float):
	var current = numbers[name]
	if current != value:
		var change: NumberChange = NumberChange.new()
		change.name = name
		change.value = value
		m_numberChanges.push_back(change)

func string_changed(_name: String, _value: float):
	pass

func show_hud_message(msg: String):
	m_hud_message_calls += 1
	m_hud_message_tick = HUD_MESSAGE_FADE_TIME
	m_hud_message.text = msg

# func hide_hud_message():
# 	m_hud_message_calls -= 1
# 	if m_hud_message_calls == 0:
# 		m_hud_message.text = ""
	
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
