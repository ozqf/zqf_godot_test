extends "res://ents/ent.gd"

onready var m_displayNode = $display

func _ready():
	m_displayNode.hide()
	var _foo = self.connect("area_entered", self, "on_area_entered")
	_foo = self.connect("body_entered", self, "on_body_entered")
	pass

func on_body_entered(_body):
	#print("TRIGGER: body entered")
	ent_trigger_targets()
	pass

func on_area_entered(_area):
	#print("TRIGGER: area entered")
	ent_trigger_targets()
	pass
