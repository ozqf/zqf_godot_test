extends Spatial

var asci:String = """########################################x  ......###############
######################################     ......###############
##########################...#### x ##x    .......##############
###################...####...####        x .###....  x  ########
###################....###......           .###....     ########
###################...####....  x   x   x  .##  x       ########
###########.....###...####....          x      x      ##########
###########.....###...###.....                        ##########
###########.....###....#.......          x    x  x . ..#########
############....###............ . k  x  .  x    x  . ..#########
############................... ..  ##x            .   #########
############................... ..####   x ....#x  .   #########
############.......#........... ..###..   ......   x x #########
#############....###..........k ..###.............. # ##########
############# x .####...#..... x..###...##......    # ##########
#############x xx       x  x x              x  x    #s##########
#############     .#######.   x .######...#.####x  .############
##############x     ######.  x. ######....#.####################
###############    x     #.x  .   #####.....####################
##################             x  ##############################
##################       x   .. #e##############################
################    #  x      .x################################
################              . #...############################
################       # x    .x#...############################
####################  x#  xx     ...############################
#####################   x    x   ...############################
#####################          x ...############################
#################### x  x          #############################
#################### x           x #############################
####################         #x    #############################
####################        x###################################
######################   #######################################
"""

var tile_t = preload("res://prefabs3d/ent_tile_3d.tscn")
var floor_t = preload("res://prefabs3d/ent_floor_3d.tscn")
var void_t = preload("res://prefabs3d/ent_void_3d.tscn")
var _isLoading:bool = false

signal load_state

var _width: int = 0
var _height: int = 0
var _cursor: int = 0
var _length: int = 0
var _spawnPos: Vector3 = Vector3()
var _txt: String = ""
var _tileScale: float = 2
var _positionStep: int = 4
const TILES_PER_FRAME = 10

func load_from_text(_txt: String):
	var _l: int = _txt.length()
	print("Make map from length: " + str(_l) + " chars")
	var width: int = 0
	var height: int = 0
	# Scan for map width
	for i in range(0, _l):
		var _c = _txt[i]
		if _c == '\r':
			print("Line end on return at index " + str(i))
			width = i
			break
		if _c == '\n':
			print("Line end on new line at index " + str(i))
			width = i
			break
	height = _l / width
	# check for an empty line at the end of the string:
	if _txt[_l - 1] == '\n':
		height -= 1
	
	print("Grid size: " + str(width) + ", " + str(height))
	# Load
	var tileScale: float = 2
	var positionStep: int = 4
	var x: int = 0
	var y: int = 0
	var z: int = 0
	for i in range(0, _l):
		var _c = _txt[i]
		if _c == '\r':
			continue
		if _c == '\n':
			# new row
			x = 0
			z += positionStep
			continue
		if _c == '#':
			spawn_block(x, y, z, tileScale, 1)
		if _c == ' ':
			spawn_block(x, y - tileScale, z, tileScale, 0)
		if _c == '.':
			spawn_block(x, y - tileScale, z, tileScale, 2)
		# next column
		x += positionStep
	print("Grid spawn complete")

func spawn_block(x: float, y: float, z: float, scale: float, type: int):
	var _pos: Vector3 = Vector3(x, y, z)
	var tile
	var scaleV3: Vector3 = Vector3(scale, scale, scale)
	if type == 0:
		tile = floor_t.instance()
	elif type == 2:
		tile = void_t.instance()
	else:
		tile = tile_t.instance()
		scaleV3.y *= 4
	add_child(tile)
	tile.transform.origin = _pos
	tile.scale = scaleV3#Vector3(scale, scale, scale)

func read_tile_char():
	var _c = _txt[_cursor]
	_cursor += 1
	if _c == '\r':
		return
	elif _c =='\n':
		_spawnPos.x = 0
		_spawnPos.y = 0
		_spawnPos.z += _positionStep
		return
	elif _c == ' ':
		var y: float = -(_tileScale * 2)
		spawn_block(_spawnPos.x, y, _spawnPos.z, _tileScale, 0)
	elif _c == '#':
		spawn_block(_spawnPos.x, 0, _spawnPos.z, _tileScale, 1)
	elif _c == '.':
		var y: float = -(_tileScale * 2) * 2
		spawn_block(_spawnPos.x, y, _spawnPos.z, _tileScale, 2)
	# TODO: replace with entity spawns
	else:
		var y: float = -(_tileScale * 2)
		spawn_block(_spawnPos.x, y, _spawnPos.z, _tileScale, 0)
	
	_spawnPos.x += _positionStep

func tick_load():
	#print("Tick proc gen")
	# spawn a few tiles per tick
	for _i in range(0, TILES_PER_FRAME):
		read_tile_char()
		if _cursor >= _length:
			end_load()
			return
	pass

func end_load():
	_isLoading = false
	print("Proc Gen complete - emit")
	emit_signal("load_state", "foo")
	pass

func begin_load(sourceText):
	_txt = sourceText
	_isLoading = true
	_cursor = 0
	_length = _txt.length()
	print("Make map from length: " + str(_length) + " chars")
	# Scan for map width
	for i in range(0, _length):
		var _c = _txt[i]
		if _c == '\r':
			print("Line end on return at index " + str(i))
			_width = i
			break
		if _c == '\n':
			print("Line end on new line at index " + str(i))
			_width = i
			break
	_height = _length / _width
	# check for an empty line at the end of the string:
	if _txt[_length - 1] == '\n':
		_height -= 1
	
	print("Grid size: " + str(_width) + ", " + str(_height))
	pass

func _ready():
	begin_load(asci)
	pass

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# destructor logic
		print("Proc gen destructor")
		pass

func _process(_delta:float):
	if _isLoading == true:
		tick_load()
	pass
	# if _initialised == false:
	# 	_initTimer -= _delta
	# 	if _initTimer < 0:
	# 		_initialised = true
	# 		load_from_text(asci)
	# pass
