extends KinematicBody

onready var hp = $health

func _ready():
	# force set team
	hp.m_team = 1
