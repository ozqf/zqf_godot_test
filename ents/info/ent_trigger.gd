extends "res://ents/ent.gd"

onready var m_displayNode = $display

export(int, "TriggerTargets", "ThrowObject", "TeleportObject" ) var triggerType: int = 0

export var throwVelocity: Vector3 = Vector3(0, 16, 0)

func _ready():
	m_displayNode.hide()
	var _foo = self.connect("area_entered", self, "on_area_entered")
	_foo = self.connect("body_entered", self, "on_body_entered")
	pass

func on_body_entered(_body):
	#print("TRIGGER: body entered")
	if triggerType == 1:
		# throw target
		var interactor = common.extract_interactor(_body)
		if !interactor:
			return
		interactor.interaction_throw(throwVelocity)

		pass
		# old
		# if !_body.has_method("interaction_throw"):
		# 	print("Trigger - object has no throw function")
		# 	return
		# _body.interaction_throw(throwVelocity)
		pass
	elif triggerType == 2:
		pass
		var interactor = common.extract_interactor(_body)
		if !interactor:
			return
		interactor.interaction_teleport(throwVelocity)

		# old
		# if !_body.has_method("interaction_teleport"):
		# 	print("Trigger - object has no teleport function")
		# 	return
		# _body.interaction_teleport(throwVelocity)
	else:
		ent_trigger_targets()
	pass

func on_area_entered(_area):
	#print("TRIGGER: area entered")
	if triggerType == 1:
		# throw target
		pass
	else:
		ent_trigger_targets()
	pass
