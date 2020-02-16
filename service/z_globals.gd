extends Node

const DEG2RAD = 0.017453292519
const RAD2DEG = 57.29577951308

var debugText: String = ""
var debugCamPos: String = ""
var bGameInputActive: bool = false

func _ready():
	print("Globals init")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func start_game():
	print("Globals - start game")
	get_tree().change_scene("res://world/game_scene.tscn")

func quit_game():
	get_tree().quit()
