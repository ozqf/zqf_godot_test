extends "res://ents/interactor_base/spatial_interactor_base.gd"

onready var m_body = $body
onready var m_unpressed: Spatial = $unpressed
onready var m_pressed: Spatial = $pressed

var m_state: int = 0
var m_tick: float = 0
var m_resetTime: float = 2
var m_hitResponse = com.create_hit_response(Enums.InteractHitResult.Damaged)

func _ready():
	m_body.set_interactor(self)

func press():
	m_tick = 0
	m_state = 1
	$body/CollisionShape.disabled = true
	pass

func _process(_delta: float):
	# awaiting press
	if m_state == 0:
		return
	# press in
	if m_state == 1:
		if m_tick >= 1:
			m_state = 2
			m_tick = 0
			return
		var from = m_unpressed.transform
		var to = m_pressed.transform
		var t = from.interpolate_with(to, m_tick)
		m_body.transform = t
		m_tick += _delta
	# await reset
	if m_state == 2:
		m_tick += _delta
		if m_tick >= m_resetTime:
			m_state = 0
			m_body.transform = m_unpressed.transform
			$body/CollisionShape.disabled = false

	pass

func interaction_take_hit(_hitData:Dictionary):
	print("Shoot switch hit")
	press()
	return m_hitResponse
