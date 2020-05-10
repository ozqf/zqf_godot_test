extends "../ent.gd"

onready var m_shape = $Area/CollisionShape

enum ItemState { Ready, Respawning, Removed }

var m_state = ItemState.Ready

var m_respawnTime: float = 5
var m_tick: float = 0

#####################################
# init
#####################################
func _ready():
	connect_events()
	
func connect_events():
	print("Item base - connect_events")
	var err = $Area.connect("area_entered", self, "on_touch_area")
	if err != OK:
		print("Item base - failed to connect area_entered")
	err = $Area.connect("body_entered", self, "on_touch_body")
	if err != OK:
		print("Item base - failed to connect body_entered")

#####################################
# callbacks
#####################################
func on_touch(_interactor):
	print("Item base on_touch")

func on_touch_area(area: Area):
	var interactor = common.extract_interactor(area)
	if interactor == null:
		print("Item base found no interactor on " + str(area.name))
		return
	on_touch(interactor)

func on_touch_body(body: Spatial):
	var interactor = common.extract_interactor(body)
	if interactor == null:
		print("Item base found no interactor on " + str(body.name))
		return
	on_touch(interactor)

#####################################
# respawning
#####################################
func deactivate():
	if m_state == ItemState.Respawning:
		return
	m_state = ItemState.Respawning
	self.hide()
	m_shape.disabled = true
	m_tick = m_respawnTime

func activate():
	m_state = ItemState.Ready
	self.show()
	m_shape.disabled = false

func _tick_respawn(_delta: float):
	if m_state == ItemState.Respawning:
		if (m_tick <= 0):
			activate()
		else:
			m_tick -= _delta

func _process(_delta: float):
	_tick_respawn(_delta)
