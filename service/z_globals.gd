extends Node

class TextCommand:
	var name: String
	var callback:FuncRef

var load_percent: float = 0

var debugText: String = ""
var playerDebugText: String = ""
var debugCamPos: String = ""
var bGameInputActive: bool = false

var game_root = null

var _observers = []
var _txtCommands = []

func _ready():
	print("Globals init")
	build_global_commands()

func _process(_delta: float):
	debugText = str(Engine.get_frames_per_second())

###########################################################################
# Global event system
###########################################################################

# Observers must have this signature:
# a public int called 'event_mask' which selects which events to receive
# a function: observe_event(msg: String, params)
# 	where obj is some type (or null) based on the msg
func add_observer(obj):
	_observers.push_back(obj)
	var txt = "Added observer (flags "
	txt += str(obj.event_mask)
	txt += ") total observers: " + str(_observers.size())
	print(txt)
#
# Observers must be manually cleaned up if a listener is removed from the node tree:
# EG:
#func _notification(what):
# 	if what == NOTIFICATION_PREDELETE:
# 		# destructor logic
# 		print("Game scene destructor")
# 		globals.remove_observer(self)
# 		pass
func remove_observer(obj):
	var i:int = _observers.find(obj)
	_observers.remove(i)
	print("Remove observer, total observers: " + str(_observers.size()))

func broadcast(txt: String, obj, event_bit: int):
	for observer in _observers:
		if (observer.event_mask & event_bit) != 0:
			observer.observe_event(txt, obj)

func load_scene(path: String):
	#broadcast("level_loading", null, common.EVENT_BIT_GAME_STATE)
	var _foo = get_tree().change_scene(path)
	var _b:Node = get_tree().get_root()
	print("New scene root name: " + _b.name)

###########################################################################
# root menu commands
###########################################################################
func start_game():
	print("Globals - start game")
	load_scene("res://world/game_scene.tscn")

func goto_title():
	print("Globals - goto title")
	load_scene("res://world/intermission_scene.tscn")

func quit_game():
	get_tree().quit()

###########################################################################
# text commands
###########################################################################

func load_map(name: String):
	var path = "res://maps/" + name + ".tscn"
	print("Globals - load map " + path)
	load_scene(path)

# I'm not very good at writing tokenise functions...
func tokenise(_text:String):
	#print("Tokenise " + _text)
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
				#print('"' + token + '"')
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

func cmd_map(tokens: PoolStringArray):
	if tokens.size() < 2:
		print("No map specified")
		return true
	load_map(tokens[1])

func cmd_exit(_tokens: PoolStringArray):
	quit_game()

func cmd_start_game(_tokens: PoolStringArray):
	start_game()

func cmd_goto_title(_tokens: PoolStringArray):
	goto_title()

# Commmands cannot be de-registered, so commands should only be on global
# objects
func register_text_command(name:String, obj, funcName):
	var cmd = TextCommand.new()
	cmd.name = name
	var callbackRef = funcref(obj, funcName)
	cmd.callback = callbackRef
	_txtCommands.push_back(cmd)

func build_global_commands():
	register_text_command(common.CMD_EXIT_APP, self, "cmd_exit")
	register_text_command(common.CMD_START_GAME, self, "cmd_start_game")
	register_text_command(common.CMD_GOTO_TITLE, self, "cmd_goto_title")
	register_text_command("map", self, "cmd_map")
	pass

func execute(command: String):
	var tokens: PoolStringArray = tokenise(command)
	if tokens.size() == 0:
		print("No command read")
		return
	
	for i in range(0, _txtCommands.size()):
		if _txtCommands[i].name == tokens[0]:
			_txtCommands[i].callback.call_func(tokens)
		pass
	pass
