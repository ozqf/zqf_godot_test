extends Node

const EVENT_BIT_GAME_STATE: int = (1 << 0)

const DEG2RAD = 0.017453292519
const RAD2DEG = 57.29577951308

var debugText: String = ""
var debugCamPos: String = ""
var bGameInputActive: bool = false

var _observers = []

func _ready():
	print("Globals init")

###########################################################################
# Global event system
###########################################################################

# Observers must have this signature:
# a public int called 'event_mask' which selects which events to receive
# a function: observe_event(msg: String)
func add_observer(obj):
	_observers.push_back(obj)
	var txt = "Added observer (flags "
	txt += str(obj.event_mask)
	txt += ") count: " + str(_observers.size())
	print(txt)

# Observers must be manually cleaned up if a listener is removed from the node tree:
# EG:
# func _notification(what):
# 	if what == NOTIFICATION_PREDELETE:
# 		# destructor logic
# 		print("Game scene destructor")
# 		globals.remove_observer(self)
# 		pass
func remove_observer(obj):
	var i:int = _observers.find(obj)
	_observers.remove(i)
	print("Remove observer, count: " + str(_observers.size()))

func broadcast(txt: String, event_bit: int):
	for observer in _observers:
		if (observer.event_mask & event_bit) != 0:
			observer.observe_event(txt)


###########################################################################
# root menu commands
###########################################################################
func start_game():
	print("Globals - start game")
	var _foo = get_tree().change_scene("res://world/game_scene.tscn")

func goto_title():
	print("Globals - goto title")
	var _foo = get_tree().change_scene("res://world/intermission_scene.tscn")

func quit_game():
	get_tree().quit()

