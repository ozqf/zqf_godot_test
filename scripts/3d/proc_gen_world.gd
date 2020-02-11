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
var _initTimer:float = 1
var _initialised:bool = false

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
			spawn_block(x, y, z, tileScale)
		# next column
		x += positionStep
	print("Grid spawn complete")
		

func spawn_block(x: float, y: float, z: float, scale: float):
	var _pos: Vector3 = Vector3(x, y, z)
	var tile = tile_t.instance()
	add_child(tile)
	tile.transform.origin = _pos
	tile.scale = Vector3(scale, scale, scale)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		# destructor logic
		print("Proc gen destructor")
		pass

#func _ready():
	#load_from_text(asci)

func _process(_delta:float):
	if _initialised == false:
		_initTimer -= _delta
		if _initTimer < 0:
			_initialised = true
			load_from_text(asci)
	pass
