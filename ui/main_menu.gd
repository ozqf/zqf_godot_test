extends CanvasLayer

var event_mask: int = common.EVENT_BIT_GAME_STATE

var _on:bool = true;
var _root = null
var _locked: bool = false

func _ready():
	_root = get_node("root")
	globals.add_observer(self)

func on():
	_on = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	globals.bGameInputActive = false
	_root.show()

func off():
	_on = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	globals.bGameInputActive = true
	_root.hide()

func toggle_menu_on():
	_on = !_on
	if _on:
		on()
	else:
		off()

func _process(_delta):
	if Input.is_action_just_released("ui_cancel"):
		#get_tree().quit()
		toggle_menu_on()


func _on_start_pressed():
	globals.start_game()

func _on_quit_pressed():
	globals.quit_game()


func _on_title_pressed():
	globals.goto_title()

	
func observe_event(msg: String):
	if msg == "level_loading":
		set_process(false)
		off()
	elif msg == "level_start":
		set_process(true)
