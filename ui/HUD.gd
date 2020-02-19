extends CanvasLayer

onready var m_debugText = $debug_text
onready var m_playerStatus = $player_status

func _process(_delta):
	# let debug text control itself
	#m_debugText.text = globals.debugText + "\n" + globals.debugCamPos
	pass
