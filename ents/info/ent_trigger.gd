extends "res://ents/ent.gd"

func _ready():
	var _foo = get_parent().connect("area_entered", self, "on_area_entered")
	_foo = get_parent().connect("body_entered", self, "on_body_entered")
	pass

func on_body_entered(_body):
	#print("TRIGGER: body entered")
	ent_trigger_targets()
	pass

func on_area_entered(_area):
	#print("TRIGGER: area entered")
	ent_trigger_targets()
	pass
