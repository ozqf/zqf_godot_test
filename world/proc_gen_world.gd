extends Spatial

var asci:String = """################
#      e       #
#              #
#      x       #
#              #
#              #
#     ....     #
#     ....     #
#     ....     #
#     ....     #
#              #
#              #
#              #
#      s       #
#              #
################
"""

var asci3:String = """#####################################      #####################
#########################      ##..          x##################
######################### #    #    x x      x##################
######################    #           .....  x####.....#########
######################    xx####   ......... ..........#########
#####   x ############   x  ##x  .......#### e.....   .#########
#####  x   x#############   ##  x   ...#####s  x      ##########
#####x   x  ####...######## ##  x   ...#######x  #.   .#########
####    #x   ###......#####       xx.######### x ..x...#########
##     x     ##.......#########   ################. ...#########
#x x #      x##.......######### ###################  x##########
## x       xx .............#### ###################   ##########
##     x         #..#.........#x############   ##  x  ###...####
#####   k        #####.....##.# ##########         x#####......#
##########       ############.# ##########         x...........#
########### x              x   x         x           .....##....
############     ##########.### ###########          ......#....
#########################...### ###########         x...........
######################......... ##...######       #####....#...#
###################............ #....######  x    #######......#
###################.......##...x#....###### x ############.....#
###################........#..# .....#####################.....#
#####################...     ..x.....#####################...###
####################### x x  .. ....############################
#######################  x   .  x...############################
#######################x xx  .   ......#########################
#######################      .  x......#########################
################x    ##x     .. .......#########################
################         #.     .#.....#########################
################         #......##.....#########################
################k        .......##.....#########################
#################   .....###...#################################
"""

var asci2:String = """########################################x  ......###############
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

var tile_t = preload("res://world/tiles/ent_tile_3d.tscn")
var floor_t = preload("res://world/tiles/ent_floor_3d.tscn")
var void_t = preload("res://world/tiles/ent_void_3d.tscn")
var enemy_t = preload("res://ents/mobs/ent_mob.tscn")
var _isLoading:bool = false

signal load_state

var m_floorY: float = -1.5

var _width: int = 0
var _height: int = 0
var _cursor: int = 0
var _length: int = 0
var _spawnPos: Vector3 = Vector3()
var _txt: String = ""
var _tileScale: float = 2
var _positionStep: int = 4
const TILES_PER_FRAME = 20

var start:Vector3 = Vector3()
var end:Vector3 = Vector3()
var mobs:PoolVector3Array = []

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
		scaleV3.y *= 2
	add_child(tile)
	tile.transform.origin = _pos
	tile.scale = scaleV3

func spawn_mob(x: float, y: float, z: float):
	var mob = enemy_t.instance()
	var pos: Vector3 = Vector3(x, y, z)
	mob.transform.origin = pos
	add_child(mob)

func read_tile_char():
	var _c = _txt[_cursor]
	_cursor += 1
	# entity check - spawn entity then fall through to
	# place floor tile beneath enemy
	if _c == '\r':
		return
	elif _c =='\n':
		_spawnPos.x = 0
		_spawnPos.y = 0
		_spawnPos.z += _positionStep
		return
	elif _c == 'x': #mob
		mobs.push_back(Vector3(_spawnPos.x, m_floorY, _spawnPos.z))
		_c = ' '
	elif _c == 's': # start pos
		start = _spawnPos
		start.y = m_floorY
		print("Start at " + str(start))
		_c = ' '
	elif _c == 'e': # end pos
		end = _spawnPos
		end.y = m_floorY
		print("End at " + str(end))
		_c = ' '
	
	# fallthrough check for tiles
	if _c == ' ':
		var y: float = -(_tileScale * 2)
		spawn_block(_spawnPos.x, y, _spawnPos.z, _tileScale, 0)
	elif _c == '#':
		spawn_block(_spawnPos.x, -2, _spawnPos.z, _tileScale, 1)
	elif _c == '.':
		var y: float = -(_tileScale * 2) * 2
		spawn_block(_spawnPos.x, y, _spawnPos.z, _tileScale, 2)
	else:
		var y: float = -(_tileScale * 2)
		spawn_block(_spawnPos.x, y, _spawnPos.z, _tileScale, 0)
	
	_spawnPos.x += _positionStep

func tick_load():
	#print("Tick proc gen")
	# spawn a few tiles per tick
	sys.load_percent = int(float(_cursor) / float(_length) * 100)
	for _i in range(0, TILES_PER_FRAME):
		read_tile_char()
		if _cursor >= _length:
			end_load()
			return
	pass

func end_load():
	_isLoading = false
	print("Proc Gen complete - emit")
	emit_signal("load_state", "done", self)
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

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# destructor logic
		print("Proc gen destructor")
		pass

func _process(_delta:float):
	if _isLoading == true:
		tick_load()
	pass
 
