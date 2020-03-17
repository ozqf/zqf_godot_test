extends CanvasLayer

var event_mask: int = common.EVENT_BIT_GAME_STATE

var _on:bool = true;
var _root = null
var _locked: bool = false

var _consoleText: LineEdit = null

func _ready():
	_root = get_node("root")
	sys.add_observer(self)
	_consoleText = get_node("root/console/console_text")
	off()

func on():
	_on = true
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	sys.bGameInputActive = false
	_consoleText.grab_focus()
	_root.show()

func off():
	_on = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	sys.bGameInputActive = true
	_root.hide()

func toggle_menu_on():
	_on = !_on
	if _on:
		on()
	else:
		off()

func _process(_delta):
	if Input.is_action_just_released("ui_cancel"):
		toggle_menu_on()
	if Input.is_action_just_released("ui_accept"):
		var command = _consoleText.text
		_consoleText.text = ""
		console.execute(command)
		pass

func _on_start_pressed():
	console.execute(common.CMD_START_GAME)

func _on_quit_pressed():
	console.execute(common.CMD_EXIT_APP)

func _on_title_pressed():
	console.execute(common.CMD_GOTO_TITLE)
	
func observe_event(msg: String, _obj):
	if msg == common.EVENT_LEVEL_LOADING:
		set_process(false)
		off()
	elif msg == common.EVENT_LEVEL_START:
		set_process(true)
