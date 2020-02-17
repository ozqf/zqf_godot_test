extends Node

const DEG2RAD = 0.017453292519
const RAD2DEG = 57.29577951308

var debugText: String = ""
var debugCamPos: String = ""
var bGameInputActive: bool = false

var _observers = []

func _ready():
	print("Globals init")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func add_observer(obj):
	_observers.push_back(obj)
	var txt = "Added observer (flags "
	txt += str(obj.event_mask)
	txt += ") count: " + str(_observers.size())
	print(txt)

func remove_observer(obj):
	var i:int = _observers.find(obj)
	_observers.remove(i)
	print("Remove observer, count: " + str(_observers.size()))

func broadcast(txt: String, event_bit: int):
	for observer in _observers:
		if (observer.event_mask & event_bit) != 0:
			observer.observe_event(txt)


func start_game():
	print("Globals - start game")
	get_tree().change_scene("res://world/game_scene.tscn")

func goto_title():
	print("Globals - goto title")
	get_tree().change_scene("res://world/intermission_scene.tscn")

func quit_game():
	get_tree().quit()
