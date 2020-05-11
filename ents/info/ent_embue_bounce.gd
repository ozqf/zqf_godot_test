extends Node


########################################
# Interactions functions
########################################

func get_interactor():
	return self

func interaction_throw(_throwVelocityPerSecond: Vector3):
	pass

func interaction_teleport(_pos: Vector3):
	pass

# Returns the quantity taken. Returns 0 if nothing can be taken
func interaction_give(_itemName: String, _amount: int):
	return 0

func interaction_get_imbue_effect():
	return "bounce"
