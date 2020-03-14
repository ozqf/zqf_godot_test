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
	globals.add_observer(self)
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
# Event response
###########################################################################
func observe_event(msg: String, _params):
	if msg == common.EVENT_LEVEL_LOADING:
		pass
	elif msg == common.EVENT_LEVEL_START:
		pass
	elif msg == common.EVENT_LEVEL_COMPLETE:
		pass
	elif msg == common.EVENT_PLAYER_SPAWN:
		register_player(_params)
	elif msg == common.EVENT_PLAYER_DIED:
		deregister_player(_params)
