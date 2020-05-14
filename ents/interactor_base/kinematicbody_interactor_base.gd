extends KinematicBody
class_name kinematicbody_interactor_base
const Enums = preload("res://Enums.gd")

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
	return ""

func interaction_take_hit(_hitData: Dictionary):
	return common.create_hit_response_dict(Enums.InteractHitResult.None)
