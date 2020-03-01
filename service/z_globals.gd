extends Node

var load_percent: float = 0

var debugText: String = ""
var debugCamPos: String = ""
var bGameInputActive: bool = false

var game_root = null

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
	txt += ") total observers: " + str(_observers.size())
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
	print("Remove observer, total observers: " + str(_observers.size()))

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

###########################################################################
# text commands
###########################################################################

func tokenise(_text:String):
	print("Tokenise " + _text)
	var tokens: PoolStringArray = []
	var _len:int = _text.length()
	var readingToken: bool = false
	var _charsInToken:int = 0
	var _tokenStart:int = 0
	var i:int = 0
	var finished:bool = false
	while (true):
		var c = _text[i]
		i += 1
		if i >= _len:
			finished = true
		var isWhiteSpace:bool = (c == " " || c == "\t")
		if readingToken:
			# finish token
			if isWhiteSpace || finished:
				if finished && !isWhiteSpace:
					# count this last char if we are making a token
					_charsInToken += 1
				readingToken = false
				var token:String = _text.substr(_tokenStart, _charsInToken)
				tokens.push_back(token)
				print('"' + token + '"')
			else:
				# increment token length
				_charsInToken += 1
		else:
			# eat whitespace
			if c == " " || c == "\t":
				pass
			else:
				# begin a new token
				readingToken = true
				_tokenStart = i - 1
				_charsInToken = 1
		if finished:
			break
	return tokens

func execute(command: String):
	var tokens: PoolStringArray = tokenise(command)
	if tokens.size() == 0:
		print("No command read")
		return
	if tokens[0] == "exit":
		quit_game()

	pass
