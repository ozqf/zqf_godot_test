extends Node

class TextCommand:
	var name: String
	var description: String
	var signature: String # leave null or empty to ignore the default signature test
	var callback:FuncRef

var _txtCommands = []

func _ready():
	register_text_command("help", self, "cmd_help", "", "Print command list")
	register_text_command("test", self, "cmd_test", "", "Test tokenisation and signature checking")
	pass

###########################################################################
# text commands
###########################################################################

func cmd_help(_tokens: PoolStringArray):
	print("=== list text commands ===")
	for i in range(0, _txtCommands.size()):
		print(_txtCommands[i].name + ": " + _txtCommands[i].description)

func cmd_test(_tokens: PoolStringArray):
	print("=== Console cmd test ===")
	var sig: String = "tfi"
	var flag: bool = check_token_signature(_tokens, sig)
	print("Check tokens " + str(_tokens) + " against signature " + sig + ": " + str(sig.length()))
	print("Num tokens: " + str(_tokens.size()))
	print("Result: " + str(flag))

###########################################################################
# token signature validation
###########################################################################
# t or s == string
# f == float
# i == int
func check_token_type(token: String, sigChar):
	if sigChar == 't':
		return true
	if sigChar == 's':
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

###########################################################################
# text command system
###########################################################################
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
			else:
				# increment token length
				_charsInToken += 1
		else:
			# eat whitespace
			if c == " " || c == "\t":
				pass
			else:
				if !finished:
					# begin a new token
					readingToken = true
					_tokenStart = i - 1
					_charsInToken = 1
				else:
					# single char token at end of line:
					var token: String = _text.substr(i -1, 1)
					tokens.push_back(token)
		if finished:
			break
	print("Tokenised '" + _text + "' to " + str(tokens))
	return tokens

# Commmands cannot be de-registered, so commands should only be on global
# objects
func register_text_command(name:String, obj, funcName, signature: String, description: String):
	# Validate
	if common.strNullOrEmpty(name):
		print("Console commands must have a name")
		return
	if common.strNullOrEmpty(funcName):
		print("Console commands must have a description")
		return
	if obj == null:
		print("Console commands cannot have a null target object")
		return
	# Create
	var cmd = TextCommand.new()
	cmd.name = name
	var callbackRef = funcref(obj, funcName)
	cmd.callback = callbackRef
	cmd.signature = signature
	cmd.description = description
	_txtCommands.push_back(cmd)

func _get_command(name: String):
	for i in range(0, _txtCommands.size()):
		if _txtCommands[i].name == name:
			return _txtCommands[i]
	return null

func execute(command: String):
	var tokens: PoolStringArray = tokenise(command)
	if tokens.size() == 0:
		print("No command read - use help to see commands")
		return
	
	var cmd: TextCommand = _get_command(tokens[0])
	if cmd == null:
		print("No command " + tokens[0] + " found")
		return
	
	if !common.strNullOrEmpty(cmd.signature) && !check_token_signature(tokens, cmd.signature):
		print("FAILED " + str(tokens) + " does not match signature " + cmd.signature)
		return
	cmd.callback.call_func(tokens)
