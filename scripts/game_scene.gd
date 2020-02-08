extends Node2D

var _enemyPrefab = preload("res://prefabs/Enemy.tscn")
var _playerPrefab = preload("res://prefabs/Player.tscn")

var _spawnMax: float = 1
var _spawnTick: float = 1
var cam: Camera2D
var plyr: Node2D

func _ready():
	print("Begin game scene")
	cam = $Camera2D
	plyr = $Player
	print("Camera: " + str(cam))
	print("Player: " + str(plyr))

func _process(delta):
	cam.position = plyr.get_node("Body").position
	var camTxt: String = "CamPos: " + str(cam.position)
	globals.debugCamPos = camTxt
	if _spawnTick >= _spawnMax:
		_spawnTick = _spawnMax
		#var enemy = _enemyPrefab.instance()
	else:
		_spawnTick -= delta
	pass
