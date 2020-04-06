extends "../ent.gd"

func on_touch(_interactor):
	print("Item base on_touch")
	pass

func on_touch_area(area: Area):
	print("Item base on_touch_area")
	var interactor = common.extract_interactor(area)
	if interactor == null:
		return
	on_touch(interactor)

func on_touch_body(body: Spatial):
	print("Item base on_touch_body")
	var interactor = common.extract_interactor(body)
	if interactor == null:
		return
	on_touch(interactor)

func connect_events():
	print("Item base - connect_events")
	var err = $Area.connect("area_entered", self, "on_touch_area")
	if err != OK:
		print("Item base - failed to connect area_entered")
	err = $Area.connect("body_entered", self, "on_touch_body")
	if err != OK:
		print("Item base - failed to connect body_entered")

#func body_entered(body: Node):


func _ready():
	connect_events()
