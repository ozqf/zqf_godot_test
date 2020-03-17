extends Node

class TextCommand:
	var name: String
	var callback:FuncRef

var _txtCommands = []

func _ready():
	build_global_commands()
	pass

###########################################################################
# text commands
###########################################################################

func cmd_sys(_tokens: PoolStringArray):
	print("=== System info ===")
	var real: Vector2 = OS.get_real_window_size()
	var scr: Vector2 = OS.get_screen_size()
	print("Real Window size " + str(real.x) + ", " + str(real.y))
	print("Screen size " + str(scr.x) + ", " + str(scr.y))
	var ratio = common.get_window_to_screen_ratio()
	print("Ratio: " + str(ratio.x) + ", " + str(ratio.y))
	pass

func cmd_help(_tokens: PoolStringArray):
	print("=== list text commands ===")
	for i in range(0, _txtCommands.size()):
		print(_txtCommands[i].name)

func cmd_test(_tokens: PoolStringArray):
	print("=== Console cmd test ===")
	var sig: String = "tfi"
	var flag: bool = check_token_signature(_tokens, sig)
	print("Check against signature " + sig + ": " + str(sig.length()))
	print("Num tokens: " + str(_tokens.size()))
	print("Result: " + str(flag))

###########################################################################
# text command system
###########################################################################
func check_token_type(token: String, sigChar):
	if sigChar == 't':
		return true
	if sigChar == 'f':
		return token.is_valid_float()
	if sigChar == 'i':
		return token.is_valid_integer()
	return false

func check_token_signature(tokens: PoolStringArray, sig: String):
	var _len: int = sig.length()
	if tokens.size() != _len:
		print("Token count to signature length mismatch")
		return false
	for i in range(0, _len):
		var c = sig[i]
		var token: String = tokens[i]
		if check_token_type(token, c) == false:
			return false
	return true

# TODO Maybe tidy this up... I'm not very good at writing tokenise functions...
func tokenise(_text:String):
	print("Tokenise " + _text)
	var tokens: PoolStringArray = []
	var _len:int = _text.length()
	if _len == 0:
		return tokens
	var readingToken: bool = false
	var _charsInToken:int = 0
	var _tokenStart:int = 0
	var i:int = 0
	var finished:bool = false
	while (true):
		var c = _text[i]
		i += 1
		if i >= _len:
			finished = true
		var isWhiteSpace:bool = (c == " " || c == "\t")
		if readingToken:
			# finish token
			if isWhiteSpace || finished:
				if finished && !isWhiteSpace:
					# count this last char if we are making a token
					_charsInToken += 1
				readingToken = false
				var token:String = _text.substr(_tokenStart, _charsInToken)
				tokens.push_back(token)
				print('"' + token + '"')
			else:
				# increment token length
				_charsInToken += 1
		else:
			# eat whitespace
			if c == " " || c == "\t":
				pass
			else:
				# begin a new token
				readingToken = true
				_tokenStart = i - 1
				_charsInToken = 1
		if finished:
			break
	return tokens

# Commmands cannot be de-registered, so commands should only be on global
# objects
func register_text_command(name:String, obj, funcName):
	var cmd = TextCommand.new()
	cmd.name = name
	var callbackRef = funcref(obj, funcName)
	cmd.callback = callbackRef
	_txtCommands.push_back(cmd)

func build_global_commands():
	register_text_command(common.CMD_SYSTEM_INFO, self, "cmd_sys")
	register_text_command("help", self, "cmd_help")
	register_text_command("test", self, "cmd_test")

func execute(command: String):
	var tokens: PoolStringArray = tokenise(command)
	if tokens.size() == 0:
		print("No command read - use help to see commands")
		return
	
	for i in range(0, _txtCommands.size()):
		if _txtCommands[i].name == tokens[0]:
			_txtCommands[i].callback.call_func(tokens)
		pass
	pass
