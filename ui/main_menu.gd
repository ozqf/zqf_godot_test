extends CanvasLayer

var _on:bool = true;
var _root = null

func _ready():
	_root = get_node("root")
	pass

func toggle_menu_on():
	_on = !_on
	if _on:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_root.show()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_root.hide()

func _process(delta):
	if Input.is_action_just_released("ui_cancel"):
		#get_tree().quit()
		toggle_menu_on()
	
	#if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:

