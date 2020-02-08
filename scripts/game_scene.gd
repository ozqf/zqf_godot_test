extends Node2D

var _enemyPrefab = preload("res://prefabs/Enemy.tscn")
var _playerPrefab = preload("res://prefabs/Player.tscn")

var _spawnMax: float = 1
var _spawnTick: float = 1

func _ready():
	print("Begin game scene")

func _process(delta):
	if _spawnTick >= _spawnMax:
		_spawnTick = _spawnMax
		#var enemy = _enemyPrefab.instance()
	else:
		_spawnTick -= delta
	pass
