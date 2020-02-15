extends CanvasLayer

var _on:bool = true;

func _ready():
	pass

func toggle_menu_on():
	_on = !_on
	if _on:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _process(delta):
	if Input.is_action_just_released("ui_cancel"):
		#get_tree().quit()
		toggle_menu_on()
	
	#if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:

