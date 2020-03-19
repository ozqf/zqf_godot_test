extends Node

var m_isLoading: bool = false
var m_loadTickMax: float = 1
var m_loadTick: float = 1

var m_current_level = null;

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

func change_level_deferred(fullPath):
	m_isLoading = true
	sys.broadcast(common.EVENT_LEVEL_LOADING, null, common.EVENT_BIT_GAME_STATE)
	if m_current_level:
		m_current_level.free()
		m_current_level = null
	var scene_class = ResourceLoader.load(fullPath)
	m_current_level = scene_class.instance()
	get_tree().get_root().add_child(m_current_level)

func change_level(fullPath):
	call_deferred("change_level_deferred", fullPath)

func make_map_path(mapName: String):
	return "res://maps/" + mapName + ".tscn"

###########################################################################
# root menu commands
###########################################################################
func start_game():
	print("Globals - start game")
	load_scene("res://world/game_scene.tscn")

func goto_title():
	print("Globals - goto title")
	#sys.broadcast(common.EVENT_LEVEL_LOADING, null, common.EVENT_BIT_GAME_STATE)
	

###########################################################################
# text commands
###########################################################################
func cmd_map(tokens: PoolStringArray):
	if tokens.size() < 2:
		print("No map specified")
		return true
	print("CMD map " + tokens[1])
	var path = make_map_path(tokens[1])
	change_level(path)

func cmd_exit(_tokens: PoolStringArray):
	get_tree().quit()

func cmd_start_game(_tokens: PoolStringArray):
	var path = make_map_path("testmap")
	#change_level("res://maps/testmap.tscn")
	change_level(path)

func cmd_goto_title(_tokens: PoolStringArray):
	change_level("res://world/intermission_scene.tscn")
