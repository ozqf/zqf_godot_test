extends Node

var load_percent: float = 0

var debugText: String = ""
var playerDebugText: String = ""
var weaponDebugText: String = ""
var mobDebugText: String = ""
var debugCamPos: String = ""
var bGameInputActive: bool = false

onready var debugDraw = $debug_draw
onready var hud = $HUD

var _observers = []
var _eventBlockMask = 0

var frameNumber = 0

var m_debugBugWindow: bool = true

func _ready():
	# HACK - larger window for my desktop machine (:
	if m_debugBugWindow:
		var scrSize: Vector2 = OS.get_screen_size()
		if scrSize.y >= 1080:
			OS.set_window_size(Vector2(1600, 900))
			OS.center_window()
	
	print("Globals init")
	console.register_text_command("observers", self, "cmd_observers", "", "List global event observers")
	console.register_text_command(common.CMD_SYSTEM_INFO, self, "cmd_sys", "", "Print system info")

func _process(_delta: float):
	debugText = str(Engine.get_frames_per_second())
	frameNumber += 1
	
###########################################################################
# Console commands
###########################################################################

func cmd_sys(_tokens: PoolStringArray):
	print("=== System info ===")
	var real: Vector2 = OS.get_real_window_size()
	var scr: Vector2 = OS.get_screen_size()
	print("Real Window size " + str(real.x) + ", " + str(real.y))
	print("Screen size " + str(scr.x) + ", " + str(scr.y))
	var ratio = common.get_window_to_screen_ratio()
	print("Ratio: " + str(ratio.x) + ", " + str(ratio.y))
	pass

func cmd_observers(_tokens: PoolStringArray):
	print("=== Global Observers ===")
	for i in range(0, _observers.size()):
		var ob = _observers[i]
		print(str(i) + ": mask " + str(ob.event_mask) + " - " + ob.name)
	
###########################################################################
# Global event system
###########################################################################

# Observers must have this signature:
# a public int called 'event_mask' which selects which events to receive
# a function: observe_event(msg: String, params)
# 	where obj is some type (or null) based on the msg
#
# Observers must be manually cleaned up if a listener is removed from the node tree:
# EG:
#func _notification(what):
# 	if what == NOTIFICATION_PREDELETE:
# 		# destructor logic
# 		sys.remove_observer(self)
# 		pass

func add_observer(obj):
	_observers.push_back(obj)

func remove_observer(obj):
	var i:int = _observers.find(obj)
	_observers.remove(i)

func broadcast(txt: String, obj, event_bit: int):
	var mask = ~_eventBlockMask
	if (event_bit & mask) == 0:
		print("BLOCKED msg " + txt)
		return
	print("Broadcast msg " + txt + ": " + str(obj))
	for observer in _observers:
		if (observer.event_mask & event_bit) != 0:
			observer.observe_event(txt, obj)

func block_event_type(bitFlag: int):
	_eventBlockMask = _eventBlockMask | bitFlag

func unblock_event_type(bitFlag: int):
	_eventBlockMask = _eventBlockMask & ~bitFlag
	
	
###########################################################################
# Scene loader
###########################################################################
