extends Node

var load_percent: float = 0

var debugText: String = ""
var playerDebugText: String = ""
var mobDebugText: String = ""
var debugCamPos: String = ""
var bGameInputActive: bool = false

var game_root = null

var _observers = []
var _eventBlockMask = 0

var frameNumber = 0

func _ready():
	print("Globals init")
	console.register_text_command("observer", self, "cmd_observer")

func _process(_delta: float):
	debugText = str(Engine.get_frames_per_second())
	frameNumber += 1
	
###########################################################################
# Console commands
###########################################################################

func cmd_observer(_tokens: PoolStringArray):
	print("=== Global Observers ===")
	for i in range(0, _observers.size()):
		var ob = _observers[i]
		print(str(i) + ": mask " + str(ob.event_mask) + " - " + str(ob))
	
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
	
