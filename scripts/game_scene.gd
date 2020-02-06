extends Node2D

var _enemyPrefab = preload("res://Enemy.tscn")
var _playerPrefab = preload("res://Player.tscn")

var _spawnMax: float = 1
var _spawnTick: float = 1

func _ready():
	print("Begin game scene")
	pass # Replace with function body.

func _process(delta):
	if _spawnTick >= _spawnMax:
		_spawnTick = _spawnMax
		var enemy = _enemyPrefab.instance()
		
	else:
		_spawnTick -= delta
	pass
