extends Node

var m_isLoading: bool = false
var m_loadTickMax: float = 1
var m_loadTick: float = 1

func _ready():
	print("Globals init")
	console.register_text_command(common.CMD_EXIT_APP, self, "cmd_exit", "", "Close the application")
	console.register_text_command(common.CMD_START_GAME, self, "cmd_start_game", "", "Start a new game")
	console.register_text_command(common.CMD_GOTO_TITLE, self, "cmd_goto_title", "", "Go to the title screen")
	console.register_text_command("map", self, "cmd_map", "tt", "Load the provided map scene. No file extension. Must be in the maps directory")
	

func _process(_delta: float):
	if !m_isLoading:
		return
	
	m_loadTick -= _delta
	if (m_loadTick <= 0):
		m_isLoading = false
		m_loadTick = m_loadTickMax
		# tell the world
		sys.broadcast(common.EVENT_LEVEL_START, null, common.EVENT_BIT_GAME_STATE)
	pass

func load_scene(path: String):
	if path == null:
		print("Load scene failed - null path")
	print("MAPS Loading " + path)
	
	sys.broadcast(common.EVENT_LEVEL_LOADING, null, common.EVENT_BIT_GAME_STATE)
	
	var _foo = get_tree().change_scene(path)
	var _b:Node = get_tree().get_root()
	m_isLoading = true
	print("New scene root name: " + _b.name)
	
###########################################################################
# root menu commands
###########################################################################

func load_map(name: String):
	var path = "res://maps/" + name + ".tscn"
	load_scene(path)

func start_game():
	print("Globals - start game")
	load_scene("res://world/game_scene.tscn")

func goto_title():
	print("Globals - goto title")
	#sys.broadcast(common.EVENT_LEVEL_LOADING, null, common.EVENT_BIT_GAME_STATE)
	load_scene("res://world/intermission_scene.tscn")

###########################################################################
# text commands
###########################################################################
func cmd_map(tokens: PoolStringArray):
	if tokens.size() < 2:
		print("No map specified")
		return true
	print("CMD map " + tokens[1])
	load_map(tokens[1])

func cmd_exit(_tokens: PoolStringArray):
	get_tree().quit()

func cmd_start_game(_tokens: PoolStringArray):
	sys.start_game()

func cmd_goto_title(_tokens: PoolStringArray):
	sys.goto_title()
