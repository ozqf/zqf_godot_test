extends "res://ents/interactor_base/kinematicbody_interactor_base.gd"

func interaction_take_hit(_hitData: Dictionary):
	print("CRATE take hit")
	return .interaction_take_hit(_hitData)
	#return common.create_hit_response_dict(Enums.InteractHitResult.None)
