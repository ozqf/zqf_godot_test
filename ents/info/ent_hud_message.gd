extends Area

export(String, MULTILINE) var message: String = ""

var m_on: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	$display.hide()
	var _result
	_result = self.connect("body_entered", self, "on_body_entered")
	_result = self.connect("body_exited", self, "on_body_exited")

func _process(_delta: float):
	if m_on:
		sys.hud.show_hud_message(message)

func on_body_entered(_body: PhysicsBody):
	print("HUD message on")
	m_on = true
	#sys.hud.show_hud_message("TEST MESSAGE")
	pass
#
func on_body_exited(_body: PhysicsBody):
	print("HUD message off")
	m_on = false
	#sys.hud.hide_hud_message()
	pass