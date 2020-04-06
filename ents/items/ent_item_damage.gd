extends "./ent_item.gd"

func on_touch(_interactor):
	print("Item Damage on_touch vs " + str(_interactor))
	# give 30 seconds of damage
	var taken: int = _interactor.interaction_give("damage", 30)
	if taken > 0:
		queue_free()
