extends "./ent_item.gd"

func on_touch(_obj:Spatial):
	print("Item Damage on_touch")
	queue_free()
