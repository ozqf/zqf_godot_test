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
		globals.bGameInputActive = false
		_root.show()
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		globals.bGameInputActive = true
		_root.hide()

func _process(delta):
	if Input.is_action_just_released("ui_cancel"):
		#get_tree().quit()
		toggle_menu_on()


func _on_start_pressed():
	globals.start_game()

func _on_quit_pressed():
	globals.quit_game()
