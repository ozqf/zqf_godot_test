extends "res://ents/interactor_base/rigidbody_interactor_base.gd"

func interaction_take_hit(_hitData: Dictionary):
	return Enums.InteractHitResult.None
