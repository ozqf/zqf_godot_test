extends "../ent.gd"

func on_touch(_obj:Spatial):
	print("Item base on_touch")
	pass

func connect_events():
	print("Item base - connect_events")
	var err = $Area.connect("area_entered", self, "on_touch")
	if err != OK:
		print("Item base - failed to connect area_entered")

func _ready():
	connect_events()
