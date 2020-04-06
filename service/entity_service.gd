extends Spatial

enum GameState { loading, ready, playing, over, complete }

var game_state = GameState.loading

var event_mask = common.EVENT_BIT_GAME_STATE | common.EVENT_BIT_ENTITY_SPAWN

var players = []
var player = null

var nextRemoteId: int = 1
var nextLocalId: int = -1
var ents = []

###########################################################################
# Init
###########################################################################
func _ready():
	print("Global entity server init")
	sys.add_observer(self)
	console.register_text_command(common.CMD_TRIGGER_ENTS, self, "cmd_trigger", "", "Trigger specified entity names")
	console.register_text_command(common.CMD_SPAWN, self, "cmd_spawn", "", "Spawn specified entity type at aim position")
	pass

func cmd_spawn(tokens: PoolStringArray):
	var numTokens = tokens.size()
	if numTokens <= 1:
		print("Must specify an entity type \neg 'mob'")
		return
	var typeName = tokens[1]
	var result: Spatial = null
	# Grab debug position global
	var pos = common.debugSpawnPosition
	# spawn
	if typeName == "mob":
		result = factory.create_mob()
	else:
		print("Unrecognised spawn type '" + typeName + "'")
		return
	# add to scene
	factory.add_to_scene_root(result, pos)
	result.transform.origin = pos
	pass

func cmd_trigger(tokens: PoolStringArray):
	var numTokens = tokens.size()
	if numTokens <= 1:
		print("Must specify entity names to trigger\neg trigger ent1 ent2 ent3")
		return
	print("Triggering " + str(numTokens - 1) + "entities")
	# skip first token natch.
	for i in range(1, numTokens):
		print("Force triggering of " + tokens[i])
		trigger_entity(tokens[i])
	pass

###########################################################################
# Entity utilities
###########################################################################
func get_enemy_target(_currentTarget, _selfPos:Vector3):
	return player

func register_player(_plyr):
	player = _plyr
	#print("Registered player")

func deregister_player(_plyr):
	player = null
	#print("Deregistered player")

###########################################################################
# Entity list
###########################################################################
func register_remote_ent(ent):
	ents.push_back(ent)
	var id = nextRemoteId
	nextRemoteId += 1
	return id

func register_local_ent(ent):
	ents.push_back(ent)
	var id = nextLocalId
	nextLocalId += 1
	return id

func deregister_ent(ent):
	var i = ents.find(ent)
	if i >= 0:
		ents.remove(i)

###########################################################################
# Broadcast triggering
###########################################################################
func trigger_entity(entName: String):
	sys.broadcast(common.EVENT_ENTITY_TRIGGER, entName, common.EVENT_BIT_ENTITY_TRIGGER)

func trigger_entities(targets: PoolStringArray):
	for i in range(0, targets.size()):
		trigger_entity(targets[i])

###########################################################################
# Event response
###########################################################################
func observe_event(msg: String, _params):
	if msg == common.EVENT_LEVEL_LOADING:
		var l: int = ents.size()
		print("ENTS - freeing " + str(l) + " ents")
		var i: int = l - 1
		while i >= 0:
			ents[i].culled = true
			ents[i].free()
			i -= 1
		ents.clear()
		pass
	elif msg == common.EVENT_LEVEL_START:
		pass
	elif msg == common.EVENT_LEVEL_COMPLETE:
		pass
	elif msg == common.EVENT_PLAYER_SPAWN:
		register_player(_params)
	elif msg == common.EVENT_PLAYER_DIED:
		deregister_player(_params)
